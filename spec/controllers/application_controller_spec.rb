# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:application) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }


end