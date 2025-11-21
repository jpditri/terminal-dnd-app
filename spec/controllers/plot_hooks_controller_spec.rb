# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlotHooksController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:plot_hooks) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:plot_hooks)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      plot_hooks = create(:plot_hooks)
      get :show, params: { id: plot_hooks.to_param }
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
      it 'creates a new PlotHooks' do
        expect {
          post :create, params: { plot_hooks: valid_attributes }
        }.to change(PlotHooks, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new PlotHooks' do
        expect {
          post :create, params: { plot_hooks: invalid_attributes }
        }.not_to change(PlotHooks, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested plot_hooks' do
        plot_hooks = create(:plot_hooks)
        put :update, params: { id: plot_hooks.to_param, plot_hooks: valid_attributes }
        plot_hooks.reload
        expect(response).to redirect_to(plot_hooks)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested plot_hooks' do
      plot_hooks = create(:plot_hooks)
      expect {
        delete :destroy, params: { id: plot_hooks.to_param }
      }.to change(PlotHooks, :count).by(-1)
    end
  end





end