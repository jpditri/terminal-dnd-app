# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BackgroundsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:backgrounds) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:backgrounds)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      backgrounds = create(:backgrounds)
      get :show, params: { id: backgrounds.to_param }
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
      it 'creates a new Backgrounds' do
        expect {
          post :create, params: { backgrounds: valid_attributes }
        }.to change(Backgrounds, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Backgrounds' do
        expect {
          post :create, params: { backgrounds: invalid_attributes }
        }.not_to change(Backgrounds, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested backgrounds' do
        backgrounds = create(:backgrounds)
        put :update, params: { id: backgrounds.to_param, backgrounds: valid_attributes }
        backgrounds.reload
        expect(response).to redirect_to(backgrounds)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested backgrounds' do
      backgrounds = create(:backgrounds)
      expect {
        delete :destroy, params: { id: backgrounds.to_param }
      }.to change(Backgrounds, :count).by(-1)
    end
  end








end