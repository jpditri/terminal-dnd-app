# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/content_librarieseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:content_libraries) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:content_libraries)
      get content_librarieseses_url
      expect(response).to be_successful
    end
  end
end