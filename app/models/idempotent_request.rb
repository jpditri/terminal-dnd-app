# frozen_string_literal: true

class IdempotentRequest < ApplicationRecord
  belongs_to :character

  validates :idempotency_key, presence: true
  validates :action_type, presence: true
  validates :status_code, presence: true
  validates :idempotency_key, uniqueness: true

end