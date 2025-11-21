# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/encounter_templateseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:encounter_templates) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:encounter_templates)
      get encounter_templateseses_url
      expect(response).to be_successful
    end
  end
end