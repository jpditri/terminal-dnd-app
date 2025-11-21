# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Homebrew::Homebrew::racesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:homebrew::races) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:homebrew::races)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      homebrew::races = create(:homebrew::races)
      get :show, params: { id: homebrew::races.to_param }
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
      it 'creates a new Homebrew::races' do
        expect {
          post :create, params: { homebrew::races: valid_attributes }
        }.to change(Homebrew::races, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Homebrew::races' do
        expect {
          post :create, params: { homebrew::races: invalid_attributes }
        }.not_to change(Homebrew::races, :count)
      end
    end
  end


  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested homebrew::races' do
        homebrew::races = create(:homebrew::races)
        put :update, params: { id: homebrew::races.to_param, homebrew::races: valid_attributes }
        homebrew::races.reload
        expect(response).to redirect_to(homebrew::races)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested homebrew::races' do
      homebrew::races = create(:homebrew::races)
      expect {
        delete :destroy, params: { id: homebrew::races.to_param }
      }.to change(Homebrew::races, :count).by(-1)
    end
  end





end