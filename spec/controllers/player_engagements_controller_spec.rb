# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlayerEngagementsController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:player_engagements) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }

  describe 'GET #index' do
    it 'returns a success response' do
      create(:player_engagements)
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      player_engagements = create(:player_engagements)
      get :show, params: { id: player_engagements.to_param }
      expect(response).to be_successful
    end
  end



end