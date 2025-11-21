# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Settings::Settings::themeController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:settings::them) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #show' do
    it 'returns a success response' do
      settings::them = create(:settings::them)
      get :show, params: { id: settings::them.to_param }
      expect(response).to be_successful
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested settings::them' do
        settings::them = create(:settings::them)
        put :update, params: { id: settings::them.to_param, settings::them: valid_attributes }
        settings::them.reload
        expect(response).to redirect_to(settings::them)
      end
    end
  end






end