# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LootTablesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:loot_tables) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:loot_tables)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      loot_tables = create(:loot_tables)
      get :show, params: { id: loot_tables.to_param }
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
      it 'creates a new LootTables' do
        expect {
          post :create, params: { loot_tables: valid_attributes }
        }.to change(LootTables, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new LootTables' do
        expect {
          post :create, params: { loot_tables: invalid_attributes }
        }.not_to change(LootTables, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested loot_tables' do
        loot_tables = create(:loot_tables)
        put :update, params: { id: loot_tables.to_param, loot_tables: valid_attributes }
        loot_tables.reload
        expect(response).to redirect_to(loot_tables)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested loot_tables' do
      loot_tables = create(:loot_tables)
      expect {
        delete :destroy, params: { id: loot_tables.to_param }
      }.to change(LootTables, :count).by(-1)
    end
  end





end