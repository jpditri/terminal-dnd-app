# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/plot_hookseses', type: :request do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:plot_hooks) }

  before { sign_in user }

  describe 'GET /index' do
    it 'renders a successful response' do
      create(:plot_hooks)
      get plot_hookseses_url
      expect(response).to be_successful
    end
  end
end