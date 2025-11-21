# frozen_string_literal: true

require 'net/http'
require 'json'

# Client for Anthropic Claude API
# Supports chat completions with tool calling for AI DM
class AnthropicClient
  attr_reader :model, :api_key, :timeout

  DEFAULT_MODEL = 'claude-sonnet-4-20250514'
  DEFAULT_TIMEOUT = 120
  API_VERSION = '2023-06-01'

  def initialize(model: nil, api_key: nil, timeout: nil)
    @model = model || ENV.fetch('ANTHROPIC_MODEL', DEFAULT_MODEL)
    @api_key = api_key || ENV.fetch('ANTHROPIC_API_KEY')
    @timeout = timeout || ENV.fetch('ANTHROPIC_TIMEOUT', DEFAULT_TIMEOUT).to_i
  end

  # Chat completion with tool support
  def chat(messages:, tools: nil, system: nil, temperature: 0.7, max_tokens: 500)
    payload = {
      model: model,
      messages: format_messages(messages),
      max_tokens: max_tokens,
      temperature: temperature
    }

    # Add system prompt if provided
    if system.present?
      payload[:system] = system
    end

    # Add tools if provided
    if tools.present?
      payload[:tools] = tools
    end

    response = post_request('/v1/messages', payload)
    parse_chat_response(response)
  end

  # Generate with tools (for AI DM)
  def generate_with_tools(prompt:, context: nil, tools: [], conversation_history: [], temperature: 0.7, max_tokens: 500)
    messages = build_messages(prompt, context, conversation_history)

    result = chat(
      messages: messages,
      tools: tools,
      temperature: temperature,
      max_tokens: max_tokens,
      system: context
    )

    {
      text: result[:content],
      tool_calls: result[:tool_calls] || [],
      usage: result[:usage]
    }
  end

  # Check if API key is configured
  def healthy?
    api_key.present?
  end

  private

  def base_uri
    'https://api.anthropic.com'
  end

  def post_request(path, payload)
    uri = URI("#{base_uri}#{path}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = timeout
    http.open_timeout = 10

    request = Net::HTTP::Post.new(uri.path)
    request['Content-Type'] = 'application/json'
    request['x-api-key'] = api_key
    request['anthropic-version'] = API_VERSION
    request.body = payload.to_json

    response = http.request(request)

    unless response.is_a?(Net::HTTPSuccess)
      error_body = JSON.parse(response.body) rescue { 'error' => response.body }
      raise "Anthropic API error: #{error_body['error']&.dig('message') || response.code}"
    end

    response
  end

  def format_messages(messages)
    # Remove system messages and handle them separately
    formatted = messages.reject { |m| m[:role] == 'system' }.map do |msg|
      {
        role: msg[:role] || msg['role'],
        content: msg[:content] || msg['content']
      }
    end

    formatted
  end

  def build_messages(prompt, context, history)
    messages = []

    # Add conversation history (excluding system messages - they go in system param)
    history.each do |entry|
      role = entry[:role] || entry['role']
      next if role == 'system'

      messages << {
        role: role,
        content: entry[:content] || entry['content']
      }
    end

    # Current user message
    messages << { role: 'user', content: prompt }

    messages
  end

  def parse_chat_response(response)
    data = JSON.parse(response.body)

    content_blocks = data['content'] || []
    text_content = content_blocks
      .select { |block| block['type'] == 'text' }
      .map { |block| block['text'] }
      .join("\n")

    tool_calls = content_blocks
      .select { |block| block['type'] == 'tool_use' }
      .map do |block|
        {
          name: block['name'],
          parameters: block['input'] || {},  # Changed from 'arguments' to 'parameters' for consistency
          reasoning: nil  # Anthropic doesn't provide reasoning separately
        }
      end

    {
      content: text_content,
      role: data['role'] || 'assistant',
      tool_calls: tool_calls,
      usage: {
        prompt_tokens: data.dig('usage', 'input_tokens') || 0,
        completion_tokens: data.dig('usage', 'output_tokens') || 0,
        total_tokens: (data.dig('usage', 'input_tokens') || 0) + (data.dig('usage', 'output_tokens') || 0)
      }
    }
  end
end
