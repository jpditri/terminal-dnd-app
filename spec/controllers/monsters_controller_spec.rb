# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MonstersController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:monsters) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:monsters)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      monsters = create(:monsters)
      get :show, params: { id: monsters.to_param }
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
      it 'creates a new Monsters' do
        expect {
          post :create, params: { monsters: valid_attributes }
        }.to change(Monsters, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Monsters' do
        expect {
          post :create, params: { monsters: invalid_attributes }
        }.not_to change(Monsters, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested monsters' do
        monsters = create(:monsters)
        put :update, params: { id: monsters.to_param, monsters: valid_attributes }
        monsters.reload
        expect(response).to redirect_to(monsters)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested monsters' do
      monsters = create(:monsters)
      expect {
        delete :destroy, params: { id: monsters.to_param }
      }.to change(Monsters, :count).by(-1)
    end
  end









end