# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:passwords) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new Passwords' do
        expect {
          post :create, params: { passwords: valid_attributes }
        }.to change(Passwords, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Passwords' do
        expect {
          post :create, params: { passwords: invalid_attributes }
        }.not_to change(Passwords, :count)
      end
    end
  end


  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested passwords' do
        passwords = create(:passwords)
        put :update, params: { id: passwords.to_param, passwords: valid_attributes }
        passwords.reload
        expect(response).to redirect_to(passwords)
      end
    end
  end



end