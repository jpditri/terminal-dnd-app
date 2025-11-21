# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DiceRollsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:dice_rolls) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:dice_rolls)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      dice_rolls = create(:dice_rolls)
      get :show, params: { id: dice_rolls.to_param }
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
      it 'creates a new DiceRolls' do
        expect {
          post :create, params: { dice_rolls: valid_attributes }
        }.to change(DiceRolls, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new DiceRolls' do
        expect {
          post :create, params: { dice_rolls: invalid_attributes }
        }.not_to change(DiceRolls, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested dice_rolls' do
        dice_rolls = create(:dice_rolls)
        put :update, params: { id: dice_rolls.to_param, dice_rolls: valid_attributes }
        dice_rolls.reload
        expect(response).to redirect_to(dice_rolls)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested dice_rolls' do
      dice_rolls = create(:dice_rolls)
      expect {
        delete :destroy, params: { id: dice_rolls.to_param }
      }.to change(DiceRolls, :count).by(-1)
    end
  end








end