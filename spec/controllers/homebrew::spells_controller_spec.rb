# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Homebrew::Homebrew::spellsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:homebrew::spells) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:homebrew::spells)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      homebrew::spells = create(:homebrew::spells)
      get :show, params: { id: homebrew::spells.to_param }
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
      it 'creates a new Homebrew::spells' do
        expect {
          post :create, params: { homebrew::spells: valid_attributes }
        }.to change(Homebrew::spells, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Homebrew::spells' do
        expect {
          post :create, params: { homebrew::spells: invalid_attributes }
        }.not_to change(Homebrew::spells, :count)
      end
    end
  end


  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested homebrew::spells' do
        homebrew::spells = create(:homebrew::spells)
        put :update, params: { id: homebrew::spells.to_param, homebrew::spells: valid_attributes }
        homebrew::spells.reload
        expect(response).to redirect_to(homebrew::spells)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested homebrew::spells' do
      homebrew::spells = create(:homebrew::spells)
      expect {
        delete :destroy, params: { id: homebrew::spells.to_param }
      }.to change(Homebrew::spells, :count).by(-1)
    end
  end





end