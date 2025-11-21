# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlignmentsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:alignments) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:alignments)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      alignments = create(:alignments)
      get :show, params: { id: alignments.to_param }
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
      it 'creates a new Alignments' do
        expect {
          post :create, params: { alignments: valid_attributes }
        }.to change(Alignments, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Alignments' do
        expect {
          post :create, params: { alignments: invalid_attributes }
        }.not_to change(Alignments, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested alignments' do
        alignments = create(:alignments)
        put :update, params: { id: alignments.to_param, alignments: valid_attributes }
        alignments.reload
        expect(response).to redirect_to(alignments)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested alignments' do
      alignments = create(:alignments)
      expect {
        delete :destroy, params: { id: alignments.to_param }
      }.to change(Alignments, :count).by(-1)
    end
  end








end