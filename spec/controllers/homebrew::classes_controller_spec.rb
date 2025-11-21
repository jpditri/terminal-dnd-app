# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Homebrew::Homebrew::classesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:homebrew::classes) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:homebrew::classes)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      homebrew::classes = create(:homebrew::classes)
      get :show, params: { id: homebrew::classes.to_param }
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
      it 'creates a new Homebrew::classes' do
        expect {
          post :create, params: { homebrew::classes: valid_attributes }
        }.to change(Homebrew::classes, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Homebrew::classes' do
        expect {
          post :create, params: { homebrew::classes: invalid_attributes }
        }.not_to change(Homebrew::classes, :count)
      end
    end
  end


  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested homebrew::classes' do
        homebrew::classes = create(:homebrew::classes)
        put :update, params: { id: homebrew::classes.to_param, homebrew::classes: valid_attributes }
        homebrew::classes.reload
        expect(response).to redirect_to(homebrew::classes)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested homebrew::classes' do
      homebrew::classes = create(:homebrew::classes)
      expect {
        delete :destroy, params: { id: homebrew::classes.to_param }
      }.to change(Homebrew::classes, :count).by(-1)
    end
  end





end