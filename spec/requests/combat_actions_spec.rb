# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/combat_actionseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:combat_actions) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:combat_actions)
      get combat_actionseses_url
      expect(response).to be_successful
    end
  end
end