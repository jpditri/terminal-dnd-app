# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CombatParticipantsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:combat_participants) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:combat_participants)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      combat_participants = create(:combat_participants)
      get :show, params: { id: combat_participants.to_param }
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
      it 'creates a new CombatParticipants' do
        expect {
          post :create, params: { combat_participants: valid_attributes }
        }.to change(CombatParticipants, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new CombatParticipants' do
        expect {
          post :create, params: { combat_participants: invalid_attributes }
        }.not_to change(CombatParticipants, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested combat_participants' do
        combat_participants = create(:combat_participants)
        put :update, params: { id: combat_participants.to_param, combat_participants: valid_attributes }
        combat_participants.reload
        expect(response).to redirect_to(combat_participants)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested combat_participants' do
      combat_participants = create(:combat_participants)
      expect {
        delete :destroy, params: { id: combat_participants.to_param }
      }.to change(CombatParticipants, :count).by(-1)
    end
  end



end