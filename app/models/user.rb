# frozen_string_literal: true

class User < ApplicationRecord
  include Discard::Model
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  has_paper_trail ignore: %i[
    encrypted_password
    reset_password_token
    reset_password_sent_at
    remember_created_at
    sign_in_count
    current_sign_in_at
    last_sign_in_at
    current_sign_in_ip
    last_sign_in_ip
  ]

  has_one :theme_preference, dependent: :destroy
  has_many :sessions, dependent: :destroy
  has_many :pivot_configurations, dependent: :destroy
  has_many :custom_pages, dependent: :destroy
  has_many :page_shares, dependent: :destroy
  has_many :shared_pages, through: :page_shares
  has_many :friendships, dependent: :destroy
  has_many :friends, through: :friendships
  has_many :sent_friend_requests, dependent: :destroy
  has_many :received_friend_requests, dependent: :destroy
  has_many :user_blocks_as_blocker, dependent: :destroy
  has_many :user_blocks_as_blocked, dependent: :destroy
  has_many :blocked_users, through: :user_blocks_as_blocker
  has_many :dm_campaigns, dependent: :destroy
  has_many :campaign_join_requests, dependent: :destroy
  has_many :campaign_ratings, dependent: :destroy
  has_many :characters, dependent: :destroy
  has_many :campaign_memberships, dependent: :destroy
  has_many :campaigns, through: :campaign_memberships
  has_many :shared_contents, dependent: :destroy
  has_many :content_clones, dependent: :destroy
  has_many :content_ratings, dependent: :destroy
  has_many :campaign_templates, dependent: :destroy
  has_many :template_ratings, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :ai_dm_suggestions, dependent: :destroy
  has_many :ai_dm_overrides, dependent: :destroy
  has_many :homebrew_items, dependent: :destroy
  has_many :spell_filter_presets, dependent: :destroy
  has_many :dice_rolls, dependent: :destroy
  has_many :chat_messages, dependent: :destroy
  has_many :received_messages, dependent: :nullify
  has_many :message_reactions, dependent: :destroy
  has_many :terminal_sessions, dependent: :destroy
  has_many :dm_pending_actions, dependent: :destroy

  validates :email, presence: true, uniqueness: true
  validates :username, uniqueness: true
  validates :discord_id, uniqueness: true, allow_nil: true

  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }
  scope :guests, -> { where(guest: true) }
  scope :with_discord, -> { where.not(discord_id: nil) }

  # Discord integration
  def discord_connected?
    discord_id.present?
  end

  def discord_display_name
    return nil unless discord_connected?

    if discord_discriminator.present? && discord_discriminator != '0'
      "#{discord_username}##{discord_discriminator}"
    else
      discord_username
    end
  end

  def discord_token_expired?
    return true unless discord_token_expires_at

    discord_token_expires_at < Time.current
  end

  def name
    display_name.presence || username.presence || discord_display_name || email.split('@').first
  end

  # AI token management
  def ai_tokens_remaining
    (ai_tokens_limit || 100000) - (ai_tokens_used || 0)
  end

  def at_ai_token_limit?
    (ai_tokens_used || 0) >= (ai_tokens_limit || 100000)
  end

  def increment_ai_tokens(amount)
    increment!(:ai_tokens_used, amount)
  end

  # Preferences
  def preference(key, default = nil)
    (preferences || {}).dig(key.to_s) || default
  end

  def set_preference(key, value)
    self.preferences = (preferences || {}).merge(key.to_s => value)
    save!
  end

  # Override to prevent password_digest from being called during serialization
  def serializable_hash(options = nil)
    options = options ? options.dup : {}
    options[:except] = Array(options[:except]) + [:password_digest]
    super(options)
  end

  def notify_via_discord?
    discord_connected? && preference('discord_notifications', true)
  end

  # Guest management
  def convert_to_registered!(email:, password:, username: nil)
    return false unless guest?

    update!(
      email: email,
      password: password,
      username: username,
      guest: false
    )
  end

  def self.cleanup_old_guests(older_than: 7.days.ago)
    guests.where('created_at < ?', older_than).destroy_all
  end
end