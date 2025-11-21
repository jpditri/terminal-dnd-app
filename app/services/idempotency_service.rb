# frozen_string_literal: true

class IdempotencyService

  def check_request(idempotency_key, character_id, action_type)
    # TODO: Implement
  end

  def store_response(idempotency_key, character_id, action_type, status, response_data)
    # TODO: Implement
  end

  def cleanup_old_records
    # TODO: Implement
  end

  def with_idempotency(idempotency_key, character_id, action_type)
    # TODO: Implement
  end
end