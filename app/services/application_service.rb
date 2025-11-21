# frozen_string_literal: true

# Base class for service objects
# Provides common patterns for command services
class ApplicationService
  def self.call(...)
    new(...).call
  end

  private

  def success(value = nil)
    Result.success(value)
  end

  def failure(error = nil, errors: [])
    Result.failure(error, errors: errors)
  end

  def validate!
    return success if valid?
    failure(:validation_failed, errors: validation_errors)
  end

  def valid?
    true
  end

  def validation_errors
    []
  end
end
