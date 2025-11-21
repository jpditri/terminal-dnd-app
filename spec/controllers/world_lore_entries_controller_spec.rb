# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorldLoreEntriesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:world_lore_entries) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:world_lore_entries)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      world_lore_entries = create(:world_lore_entries)
      get :show, params: { id: world_lore_entries.to_param }
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
      it 'creates a new WorldLoreEntries' do
        expect {
          post :create, params: { world_lore_entries: valid_attributes }
        }.to change(WorldLoreEntries, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new WorldLoreEntries' do
        expect {
          post :create, params: { world_lore_entries: invalid_attributes }
        }.not_to change(WorldLoreEntries, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested world_lore_entries' do
        world_lore_entries = create(:world_lore_entries)
        put :update, params: { id: world_lore_entries.to_param, world_lore_entries: valid_attributes }
        world_lore_entries.reload
        expect(response).to redirect_to(world_lore_entries)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested world_lore_entries' do
      world_lore_entries = create(:world_lore_entries)
      expect {
        delete :destroy, params: { id: world_lore_entries.to_param }
      }.to change(WorldLoreEntries, :count).by(-1)
    end
  end








end