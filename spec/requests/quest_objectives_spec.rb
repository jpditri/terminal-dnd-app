# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/quest_objectiveseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:quest_objectives) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:quest_objectives)
      get quest_objectiveseses_url
      expect(response).to be_successful
    end
  end
end