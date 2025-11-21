# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Terminal Session', type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:cuprite)
  end

  describe 'Health check' do
    it 'shows health status' do
      visit '/up'
      expect(page).to have_css('body[style*="green"]')
    end
  end

  describe 'Terminal page' do
    context 'when not logged in' do
      it 'allows access as guest' do
        visit root_path
        # Should allow guest access to terminal
        expect(page.status_code).to eq(200)
      end
    end

    context 'when logged in' do
      before do
        # Use Devise test helpers for system tests
        login_as(user, scope: :user)
      end

      it 'displays the terminal interface' do
        visit root_path
        # The page should load without error
        expect(page.status_code).to eq(200)
      end

      it 'creates a new terminal session' do
        visit new_terminal_session_path
        # The app redirects to /terminal after creating a new session
        expect(page).to have_current_path(/terminal/)
      end
    end
  end

  describe 'Guest access' do
    it 'creates guest session when not authenticated' do
      visit root_path
      # Should either show terminal or handle guest access
      expect(page.status_code).to be_in([200, 302])
    end
  end
end
