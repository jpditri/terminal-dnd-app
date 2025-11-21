# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Campaigns::Campaigns::questsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:campaigns::quests) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:campaigns::quests)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      campaigns::quests = create(:campaigns::quests)
      get :show, params: { id: campaigns::quests.to_param }
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
      it 'creates a new Campaigns::quests' do
        expect {
          post :create, params: { campaigns::quests: valid_attributes }
        }.to change(Campaigns::quests, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Campaigns::quests' do
        expect {
          post :create, params: { campaigns::quests: invalid_attributes }
        }.not_to change(Campaigns::quests, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested campaigns::quests' do
        campaigns::quests = create(:campaigns::quests)
        put :update, params: { id: campaigns::quests.to_param, campaigns::quests: valid_attributes }
        campaigns::quests.reload
        expect(response).to redirect_to(campaigns::quests)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested campaigns::quests' do
      campaigns::quests = create(:campaigns::quests)
      expect {
        delete :destroy, params: { id: campaigns::quests.to_param }
      }.to change(Campaigns::quests, :count).by(-1)
    end
  end









end