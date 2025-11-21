# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/shared_contentseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:shared_contents) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:shared_contents)
      get shared_contentseses_url
      expect(response).to be_successful
    end
  end
end