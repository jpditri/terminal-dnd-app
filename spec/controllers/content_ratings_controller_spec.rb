# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContentRatingsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:content_ratings) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new ContentRatings' do
        expect {
          post :create, params: { content_ratings: valid_attributes }
        }.to change(ContentRatings, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new ContentRatings' do
        expect {
          post :create, params: { content_ratings: invalid_attributes }
        }.not_to change(ContentRatings, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested content_ratings' do
        content_ratings = create(:content_ratings)
        put :update, params: { id: content_ratings.to_param, content_ratings: valid_attributes }
        content_ratings.reload
        expect(response).to redirect_to(content_ratings)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested content_ratings' do
      content_ratings = create(:content_ratings)
      expect {
        delete :destroy, params: { id: content_ratings.to_param }
      }.to change(ContentRatings, :count).by(-1)
    end
  end





end