# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/campaign_noteseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaign_notes) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:campaign_notes)
      get campaign_noteseses_url
      expect(response).to be_successful
    end
  end
end