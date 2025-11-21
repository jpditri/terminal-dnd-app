# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CombatActionsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:combat_actions) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:combat_actions)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      combat_actions = create(:combat_actions)
      get :show, params: { id: combat_actions.to_param }
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
      it 'creates a new CombatActions' do
        expect {
          post :create, params: { combat_actions: valid_attributes }
        }.to change(CombatActions, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CombatActions' do
        expect {
          post :create, params: { combat_actions: invalid_attributes }
        }.not_to change(CombatActions, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested combat_actions' do
        combat_actions = create(:combat_actions)
        put :update, params: { id: combat_actions.to_param, combat_actions: valid_attributes }
        combat_actions.reload
        expect(response).to redirect_to(combat_actions)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested combat_actions' do
      combat_actions = create(:combat_actions)
      expect {
        delete :destroy, params: { id: combat_actions.to_param }
      }.to change(CombatActions, :count).by(-1)
    end
  end



end