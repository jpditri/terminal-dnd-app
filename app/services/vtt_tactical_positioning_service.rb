# frozen_string_literal: true

class VttTacticalPositioningService
  def call
    validate_inputs
      .and_then { |ctx| perform(ctx) }
  end

  private

  def validate_inputs
    Result.success({})
  end

  def perform(ctx)
    # TODO: Implement\nResult.success(ctx)
  end

end