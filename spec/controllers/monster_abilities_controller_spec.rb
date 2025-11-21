# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MonsterAbilitiesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:monster_abilities) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:monster_abilities)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      monster_abilities = create(:monster_abilities)
      get :show, params: { id: monster_abilities.to_param }
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
      it 'creates a new MonsterAbilities' do
        expect {
          post :create, params: { monster_abilities: valid_attributes }
        }.to change(MonsterAbilities, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new MonsterAbilities' do
        expect {
          post :create, params: { monster_abilities: invalid_attributes }
        }.not_to change(MonsterAbilities, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested monster_abilities' do
        monster_abilities = create(:monster_abilities)
        put :update, params: { id: monster_abilities.to_param, monster_abilities: valid_attributes }
        monster_abilities.reload
        expect(response).to redirect_to(monster_abilities)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested monster_abilities' do
      monster_abilities = create(:monster_abilities)
      expect {
        delete :destroy, params: { id: monster_abilities.to_param }
      }.to change(MonsterAbilities, :count).by(-1)
    end
  end








end