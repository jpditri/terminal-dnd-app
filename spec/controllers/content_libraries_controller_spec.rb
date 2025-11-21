# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContentLibrariesController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:content_libraries) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:content_libraries)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      content_libraries = create(:content_libraries)
      get :show, params: { id: content_libraries.to_param }
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
      it 'creates a new ContentLibraries' do
        expect {
          post :create, params: { content_libraries: valid_attributes }
        }.to change(ContentLibraries, :count).by(1)
      end
    end

    context 'with invalid params' do
      it 'does not create a new ContentLibraries' do
        expect {
          post :create, params: { content_libraries: invalid_attributes }
        }.not_to change(ContentLibraries, :count)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      it 'updates the requested content_libraries' do
        content_libraries = create(:content_libraries)
        put :update, params: { id: content_libraries.to_param, content_libraries: valid_attributes }
        content_libraries.reload
        expect(response).to redirect_to(content_libraries)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested content_libraries' do
      content_libraries = create(:content_libraries)
      expect {
        delete :destroy, params: { id: content_libraries.to_param }
      }.to change(ContentLibraries, :count).by(-1)
    end
  end





end