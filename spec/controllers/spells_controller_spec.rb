# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpellsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:spells) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:spells)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      spells = create(:spells)
      get :show, params: { id: spells.to_param }
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
      it 'creates a new Spells' do
        expect {
          post :create, params: { spells: valid_attributes }
        }.to change(Spells, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Spells' do
        expect {
          post :create, params: { spells: invalid_attributes }
        }.not_to change(Spells, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested spells' do
        spells = create(:spells)
        put :update, params: { id: spells.to_param, spells: valid_attributes }
        spells.reload
        expect(response).to redirect_to(spells)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested spells' do
      spells = create(:spells)
      expect {
        delete :destroy, params: { id: spells.to_param }
      }.to change(Spells, :count).by(-1)
    end
  end








end