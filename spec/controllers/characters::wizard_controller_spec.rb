# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Characters::Characters::wizardController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) { attributes_for(:characters::wizard) }
  let(:invalid_attributes) { { name: '' } }

  before { sign_in user }






















end