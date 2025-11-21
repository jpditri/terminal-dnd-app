# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NotificationsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:notifications) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:notifications)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested notifications' do
      notifications = create(:notifications)
      expect {
        delete :destroy, params: { id: notifications.to_param }
      }.to change(Notifications, :count).by(-1)
    end
  end







end