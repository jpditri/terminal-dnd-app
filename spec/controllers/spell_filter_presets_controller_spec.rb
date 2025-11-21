# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SpellFilterPresetsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:spell_filter_presets) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:spell_filter_presets)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      spell_filter_presets = create(:spell_filter_presets)
      get :show, params: { id: spell_filter_presets.to_param }
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
      it 'creates a new SpellFilterPresets' do
        expect {
          post :create, params: { spell_filter_presets: valid_attributes }
        }.to change(SpellFilterPresets, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new SpellFilterPresets' do
        expect {
          post :create, params: { spell_filter_presets: invalid_attributes }
        }.not_to change(SpellFilterPresets, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested spell_filter_presets' do
        spell_filter_presets = create(:spell_filter_presets)
        put :update, params: { id: spell_filter_presets.to_param, spell_filter_presets: valid_attributes }
        spell_filter_presets.reload
        expect(response).to redirect_to(spell_filter_presets)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested spell_filter_presets' do
      spell_filter_presets = create(:spell_filter_presets)
      expect {
        delete :destroy, params: { id: spell_filter_presets.to_param }
      }.to change(SpellFilterPresets, :count).by(-1)
    end
  end










end