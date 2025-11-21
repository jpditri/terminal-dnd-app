# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegistrationsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:registrations) }
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
      it 'creates a new Registrations' do
        expect {
          post :create, params: { registrations: valid_attributes }
        }.to change(Registrations, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new Registrations' do
        expect {
          post :create, params: { registrations: invalid_attributes }
        }.not_to change(Registrations, :count)
      end
    end
  end


end