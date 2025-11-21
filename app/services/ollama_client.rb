# frozen_string_literal: true

require 'net/http'
require 'json'

# Client for Ollama local LLM API
# Supports chat completions with tool calling for AI DM
class OllamaClient
  attr_reader :model, :host, :port, :timeout

  DEFAULT_HOST = 'localhost'
  DEFAULT_PORT = 11434
  DEFAULT_MODEL = 'wizard-vicuna-uncensored:30b'
  DEFAULT_TIMEOUT = 120

  def initialize(model: nil, host: nil, port: nil, timeout: nil)
    @model = model || ENV.fetch('OLLAMA_MODEL', DEFAULT_MODEL)
    @host = host || ENV.fetch('OLLAMA_HOST', DEFAULT_HOST)
    @port = port || ENV.fetch('OLLAMA_PORT', DEFAULT_PORT).to_i
    @timeout = timeout || ENV.fetch('OLLAMA_TIMEOUT', DEFAULT_TIMEOUT).to_i
  end

  # Chat completion with tool support
  def chat(messages:, tools: nil, temperature: 0.7, max_tokens: 4096, stream: false)
    payload = {
      model: model,
      messages: format_messages(messages),
      stream: stream,
      options: {
        temperature: temperature,
        num_predict: max_tokens
      }
    }

    # Add tools if provided (Ollama supports function calling)
    if tools.present?
      payload[:tools] = format_tools_for_ollama(tools)
    end

    response = post_request('/api/chat', payload)
    parse_chat_response(response)
  end

  # Simple text generation
  def generate(prompt:, system: nil, temperature: 0.7, max_tokens: 4096)
    payload = {
      model: model,
      prompt: prompt,
      stream: false,
      options: {
        temperature: temperature,
        num_predict: max_tokens
      }
    }
    payload[:system] = system if system.present?

    response = post_request('/api/generate', payload)
    parse_generate_response(response)
  end

  # Generate with tools (for AI DM)
  def generate_with_tools(prompt:, context: nil, tools: [], conversation_history: [], temperature: 0.7, max_tokens: 2000)
    messages = build_messages(prompt, context, conversation_history)

    result = chat(
      messages: messages,
      tools: tools,
      temperature: temperature,
      max_tokens: max_tokens
    )

    {
      text: result[:content],
      tool_calls: result[:tool_calls] || [],
      usage: result[:usage]
    }
  end

  # Check if Ollama is running and model is available
  def healthy?
    response = get_request('/api/tags')
    models = JSON.parse(response.body)['models'] || []
    models.any? { |m| m['name'].start_with?(model) }
  rescue StandardError
    false
  end

  # List available models
  def list_models
    response = get_request('/api/tags')
    data = JSON.parse(response.body)
    data['models']&.map { |m| m['name'] } || []
  rescue StandardError => e
    Rails.logger.error "[OllamaClient] Failed to list models: #{e.message}"
    []
  end

  # Pull a model if not available
  def pull_model(model_name = nil)
    target = model_name || model
    Rails.logger.info "[OllamaClient] Pulling model: #{target}"

    payload = { name: target, stream: false }
    response = post_request('/api/pull', payload, timeout: 600)
    JSON.parse(response.body)
  end

  # Get model info
  def model_info(model_name = nil)
    target = model_name || model
    response = post_request('/api/show', { name: target })
    JSON.parse(response.body)
  rescue StandardError => e
    Rails.logger.error "[OllamaClient] Failed to get model info: #{e.message}"
    nil
  end

  private

  def base_uri
    "http://#{host}:#{port}"
  end

  def post_request(path, payload, timeout: nil)
    uri = URI("#{base_uri}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = timeout || self.timeout
    http.open_timeout = 10

    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request.body = payload.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      error_body = JSON.parse(response.body) rescue { 'error' => response.body }
      raise "Ollama API error: #{error_body['error'] || response.code}"
    end

    response
  end

  def get_request(path)
    uri = URI("#{base_uri}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.read_timeout = timeout
    http.open_timeout = 10

    request = Net::HTTP::Get.new(uri.path)
    http.request(request)
  end

  def format_messages(messages)
    messages.map do |msg|
      {
        role: msg[:role] || msg['role'],
        content: msg[:content] || msg['content']
      }
    end
  end

  def format_tools_for_ollama(tools)
    # Convert from Claude/OpenAI format to Ollama format
    tools.map do |tool|
      {
        type: 'function',
        function: {
          name: tool[:name] || tool['name'],
          description: tool[:description] || tool['description'],
          parameters: tool[:input_schema] || tool[:parameters] || tool['input_schema'] || {}
        }
      }
    end
  end

  def build_messages(prompt, context, history)
    messages = []

    # System message with DM context
    if context.present?
      system_content = build_system_prompt(context)
      messages << { role: 'system', content: system_content }
    end

    # Conversation history
    history.each do |entry|
      messages << {
        role: entry[:role] || entry['role'],
        content: entry[:content] || entry['content']
      }
    end

    # Current user message
    messages << { role: 'user', content: prompt }

    messages
  end

  def build_system_prompt(context)
    <<~SYSTEM
      You are an AI Dungeon Master for a D&D 5e game. You have access to tools to manage the game state.

      Current Game State:
      #{context.to_json}

      Guidelines:
      - Be creative and engaging in your narration
      - Follow D&D 5e rules accurately
      - Use tools to modify game state when appropriate
      - Ask for player input when decisions are needed
      - Keep responses concise but flavorful
    SYSTEM
  end

  def parse_chat_response(response)
    data = JSON.parse(response.body)

    result = {
      content: data.dig('message', 'content') || '',
      role: data.dig('message', 'role') || 'assistant',
      tool_calls: [],
      usage: {
        prompt_tokens: data.dig('prompt_eval_count') || 0,
        completion_tokens: data.dig('eval_count') || 0,
        total_tokens: (data.dig('prompt_eval_count') || 0) + (data.dig('eval_count') || 0)
      }
    }

    # Parse tool calls if present
    if data.dig('message', 'tool_calls').present?
      result[:tool_calls] = data['message']['tool_calls'].map do |tc|
        {
          name: tc.dig('function', 'name'),
          parameters: tc.dig('function', 'arguments') || {},  # Changed from 'arguments' to 'parameters'
          reasoning: nil  # Ollama doesn't provide reasoning separately
        }
      end
    end

    result
  end

  def parse_generate_response(response)
    data = JSON.parse(response.body)

    {
      content: data['response'] || '',
      usage: {
        prompt_tokens: data['prompt_eval_count'] || 0,
        completion_tokens: data['eval_count'] || 0,
        total_tokens: (data['prompt_eval_count'] || 0) + (data['eval_count'] || 0)
      }
    }
  end
end
