# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TemplateRatingsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:template_ratings) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new TemplateRatings' do
        expect {
          post :create, params: { template_ratings: valid_attributes }
        }.to change(TemplateRatings, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new TemplateRatings' do
        expect {
          post :create, params: { template_ratings: invalid_attributes }
        }.not_to change(TemplateRatings, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested template_ratings' do
        template_ratings = create(:template_ratings)
        put :update, params: { id: template_ratings.to_param, template_ratings: valid_attributes }
        template_ratings.reload
        expect(response).to redirect_to(template_ratings)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested template_ratings' do
      template_ratings = create(:template_ratings)
      expect {
        delete :destroy, params: { id: template_ratings.to_param }
      }.to change(TemplateRatings, :count).by(-1)
    end
  end





end