# frozen_string_literal: true

# Result class for service objects
# Provides railway-oriented programming pattern
class Result
  attr_reader :value, :error, :errors

  def initialize(success:, value: nil, error: nil, errors: [])
    @success = success
    @value = value
    @error = error
    @errors = errors
  end

  def success?
    @success
  end

  def failure?
    !@success
  end

  def and_then
    return self if failure?
    yield(@value)
  end

  def map
    return self if failure?
    Result.success(yield(@value))
  end

  def or_else
    return self if success?
    yield(@error || @errors)
  end

  def unwrap_or(default)
    success? ? @value : default
  end

  def to_h
    if success?
      { success: true, data: @value }
    else
      { success: false, error: @error, errors: @errors }
    end
  end

  class << self
    def success(value = nil)
      new(success: true, value: value)
    end

    def failure(error = nil, errors: [])
      new(success: false, error: error, errors: errors)
    end
  end
end
