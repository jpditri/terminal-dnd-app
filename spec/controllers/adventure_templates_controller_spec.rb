# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AdventureTemplatesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:adventure_templates) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:adventure_templates)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      adventure_templates = create(:adventure_templates)
      get :show, params: { id: adventure_templates.to_param }
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
      it 'creates a new AdventureTemplates' do
        expect {
          post :create, params: { adventure_templates: valid_attributes }
        }.to change(AdventureTemplates, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new AdventureTemplates' do
        expect {
          post :create, params: { adventure_templates: invalid_attributes }
        }.not_to change(AdventureTemplates, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested adventure_templates' do
        adventure_templates = create(:adventure_templates)
        put :update, params: { id: adventure_templates.to_param, adventure_templates: valid_attributes }
        adventure_templates.reload
        expect(response).to redirect_to(adventure_templates)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested adventure_templates' do
      adventure_templates = create(:adventure_templates)
      expect {
        delete :destroy, params: { id: adventure_templates.to_param }
      }.to change(AdventureTemplates, :count).by(-1)
    end
  end








end