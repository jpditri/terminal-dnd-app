# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TerminalSession, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:character).optional }
    it { should belong_to(:dungeon_map).optional }
    it { should belong_to(:solo_session).optional }
  end

  describe 'validations' do
    # User presence is validated via belongs_to association
  end

  describe 'callbacks' do
    it 'generates a session token before validation' do
      user = create(:user)
      session = build(:terminal_session, user: user, session_token: nil)
      session.valid?
      expect(session.session_token).to be_present
    end
  end

  describe 'factory' do
    it 'creates a valid terminal session' do
      session = build(:terminal_session)
      expect(session).to be_valid
    end

    # Character creation requires additional setup (campaign, etc.)
    # TODO: Add integration test for terminal session with character
  end

  describe 'defaults' do
    let(:session) { create(:terminal_session) }

    it 'defaults mode to exploration' do
      expect(session.mode).to eq('exploration')
    end

    it 'defaults active to true' do
      expect(session.active).to be true
    end

    it 'defaults map_render_mode to ascii' do
      expect(session.map_render_mode).to eq('ascii')
    end
  end
end
