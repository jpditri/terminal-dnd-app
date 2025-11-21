# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LanguagesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:languages) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:languages)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      languages = create(:languages)
      get :show, params: { id: languages.to_param }
      expect(response).to be_successful
    end
  end


  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Languages' do
        expect {
          post :create, params: { languages: valid_attributes }
        }.to change(Languages, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Languages' do
        expect {
          post :create, params: { languages: invalid_attributes }
        }.not_to change(Languages, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested languages' do
        languages = create(:languages)
        put :update, params: { id: languages.to_param, languages: valid_attributes }
        languages.reload
        expect(response).to redirect_to(languages)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested languages' do
      languages = create(:languages)
      expect {
        delete :destroy, params: { id: languages.to_param }
      }.to change(Languages, :count).by(-1)
    end
  end








end