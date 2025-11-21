# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DungeonTemplatesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:dungeon_templates) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:dungeon_templates)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      dungeon_templates = create(:dungeon_templates)
      get :show, params: { id: dungeon_templates.to_param }
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
      it 'creates a new DungeonTemplates' do
        expect {
          post :create, params: { dungeon_templates: valid_attributes }
        }.to change(DungeonTemplates, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new DungeonTemplates' do
        expect {
          post :create, params: { dungeon_templates: invalid_attributes }
        }.not_to change(DungeonTemplates, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested dungeon_templates' do
        dungeon_templates = create(:dungeon_templates)
        put :update, params: { id: dungeon_templates.to_param, dungeon_templates: valid_attributes }
        dungeon_templates.reload
        expect(response).to redirect_to(dungeon_templates)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested dungeon_templates' do
      dungeon_templates = create(:dungeon_templates)
      expect {
        delete :destroy, params: { id: dungeon_templates.to_param }
      }.to change(DungeonTemplates, :count).by(-1)
    end
  end





end