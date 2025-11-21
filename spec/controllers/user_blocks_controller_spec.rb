# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserBlocksController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:user_blocks) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:user_blocks)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new UserBlocks' do
        expect {
          post :create, params: { user_blocks: valid_attributes }
        }.to change(UserBlocks, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new UserBlocks' do
        expect {
          post :create, params: { user_blocks: invalid_attributes }
        }.not_to change(UserBlocks, :count)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested user_blocks' do
      user_blocks = create(:user_blocks)
      expect {
        delete :destroy, params: { id: user_blocks.to_param }
      }.to change(UserBlocks, :count).by(-1)
    end
  end



end