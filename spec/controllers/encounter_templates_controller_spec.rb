# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EncounterTemplatesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:encounter_templates) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:encounter_templates)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      encounter_templates = create(:encounter_templates)
      get :show, params: { id: encounter_templates.to_param }
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
      it 'creates a new EncounterTemplates' do
        expect {
          post :create, params: { encounter_templates: valid_attributes }
        }.to change(EncounterTemplates, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new EncounterTemplates' do
        expect {
          post :create, params: { encounter_templates: invalid_attributes }
        }.not_to change(EncounterTemplates, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested encounter_templates' do
        encounter_templates = create(:encounter_templates)
        put :update, params: { id: encounter_templates.to_param, encounter_templates: valid_attributes }
        encounter_templates.reload
        expect(response).to redirect_to(encounter_templates)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested encounter_templates' do
      encounter_templates = create(:encounter_templates)
      expect {
        delete :destroy, params: { id: encounter_templates.to_param }
      }.to change(EncounterTemplates, :count).by(-1)
    end
  end





end