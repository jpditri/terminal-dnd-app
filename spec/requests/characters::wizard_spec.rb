# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/characters::wizardses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:characters::wizard) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:characters::wizard)
      get characters::wizardses_url
      expect(response).to be_successful
    end
  end
end