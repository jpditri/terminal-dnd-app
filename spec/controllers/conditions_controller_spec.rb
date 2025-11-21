# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ConditionsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:conditions) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:conditions)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      conditions = create(:conditions)
      get :show, params: { id: conditions.to_param }
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
      it 'creates a new Conditions' do
        expect {
          post :create, params: { conditions: valid_attributes }
        }.to change(Conditions, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Conditions' do
        expect {
          post :create, params: { conditions: invalid_attributes }
        }.not_to change(Conditions, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested conditions' do
        conditions = create(:conditions)
        put :update, params: { id: conditions.to_param, conditions: valid_attributes }
        conditions.reload
        expect(response).to redirect_to(conditions)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested conditions' do
      conditions = create(:conditions)
      expect {
        delete :destroy, params: { id: conditions.to_param }
      }.to change(Conditions, :count).by(-1)
    end
  end








end