# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IdempotentRequest, type: :model do
  describe 'associations' do
    it { should belong_to(:character) }
  end

  describe 'validations' do
    it { should validate_presence_of(:idempotency_key) }
    it { should validate_presence_of(:action_type) }
    it { should validate_presence_of(:status_code) }
    it { should validate_uniqueness_of(:idempotency_key) }
  end

end