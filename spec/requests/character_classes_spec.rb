# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/character_classeseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_classes) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:character_classes)
      get character_classeseses_url
      expect(response).to be_successful
    end
  end
end