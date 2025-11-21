# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_one(:theme_preference).dependent(:destroy) }
    it { should have_many(:sessions).dependent(:destroy) }
    it { should have_many(:pivot_configurations).dependent(:destroy) }
    it { should have_many(:custom_pages).dependent(:destroy) }
    it { should have_many(:page_shares).dependent(:destroy) }
    it { should have_many(:shared_pages).through(:page_shares) }
    it { should have_many(:friendships).dependent(:destroy) }
    it { should have_many(:friends).through(:friendships) }
    it { should have_many(:sent_friend_requests).dependent(:destroy) }
    it { should have_many(:received_friend_requests).dependent(:destroy) }
    it { should have_many(:user_blocks_as_blocker).dependent(:destroy) }
    it { should have_many(:user_blocks_as_blocked).dependent(:destroy) }
    it { should have_many(:blocked_users).through(:user_blocks_as_blocker) }
    it { should have_many(:dm_campaigns).dependent(:destroy) }
    it { should have_many(:campaign_join_requests).dependent(:destroy) }
    it { should have_many(:campaign_ratings).dependent(:destroy) }
    it { should have_many(:characters).dependent(:destroy) }
    it { should have_many(:campaign_memberships).dependent(:destroy) }
    it { should have_many(:campaigns).through(:campaign_memberships) }
    it { should have_many(:shared_contents).dependent(:destroy) }
    it { should have_many(:content_clones).dependent(:destroy) }
    it { should have_many(:content_ratings).dependent(:destroy) }
    it { should have_many(:campaign_templates).dependent(:destroy) }
    it { should have_many(:template_ratings).dependent(:destroy) }
    it { should have_many(:notifications).dependent(:destroy) }
    it { should have_many(:ai_dm_suggestions).dependent(:destroy) }
    it { should have_many(:ai_dm_overrides).dependent(:destroy) }
    it { should have_many(:homebrew_items).dependent(:destroy) }
    it { should have_many(:spell_filter_presets).dependent(:destroy) }
    it { should have_many(:dice_rolls).dependent(:destroy) }
    it { should have_many(:chat_messages).dependent(:destroy) }
    it { should have_many(:received_messages).dependent(:nullify) }
    it { should have_many(:message_reactions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:username) }
  end

end