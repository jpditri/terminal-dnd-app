# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CharacterClassesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:character_classes) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:character_classes)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      character_classes = create(:character_classes)
      get :show, params: { id: character_classes.to_param }
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
      it 'creates a new CharacterClasses' do
        expect {
          post :create, params: { character_classes: valid_attributes }
        }.to change(CharacterClasses, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CharacterClasses' do
        expect {
          post :create, params: { character_classes: invalid_attributes }
        }.not_to change(CharacterClasses, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested character_classes' do
        character_classes = create(:character_classes)
        put :update, params: { id: character_classes.to_param, character_classes: valid_attributes }
        character_classes.reload
        expect(response).to redirect_to(character_classes)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested character_classes' do
      character_classes = create(:character_classes)
      expect {
        delete :destroy, params: { id: character_classes.to_param }
      }.to change(CharacterClasses, :count).by(-1)
    end
  end








end