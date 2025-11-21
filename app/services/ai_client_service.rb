# frozen_string_literal: true

class AiClientService
  attr_reader :provider

  def initialize(provider: Provider.new)
    @provider = provider
  end


  def generate_completion(prompt:, context: nil, max_tokens: 1000, temperature: 0.7)
    # TODO: Implement
  end

  def test_connection
    # TODO: Implement
  end

  def current_model
    # TODO: Implement
  end

  def pricing_info
    # TODO: Implement
  end

  def calculate_cost(tokens)
    # TODO: Implement
  end
end