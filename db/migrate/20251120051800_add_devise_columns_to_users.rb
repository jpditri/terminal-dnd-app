# frozen_string_literal: true

class AddDeviseColumnsToUsers < ActiveRecord::Migration[7.1]
  def change
    # Add Devise columns
    add_column :users, :encrypted_password, :string, null: false, default: ''
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
    add_column :users, :remember_created_at, :datetime
    add_column :users, :sign_in_count, :integer, default: 0, null: false
    add_column :users, :current_sign_in_at, :datetime
    add_column :users, :last_sign_in_at, :datetime
    add_column :users, :current_sign_in_ip, :string
    add_column :users, :last_sign_in_ip, :string

    # Guest user support
    add_column :users, :guest, :boolean, default: false
    add_column :users, :display_name, :string

    # Discord columns
    add_column :users, :discord_id, :string
    add_column :users, :discord_username, :string
    add_column :users, :discord_discriminator, :string
    add_column :users, :discord_avatar, :string
    add_column :users, :discord_access_token, :string
    add_column :users, :discord_refresh_token, :string
    add_column :users, :discord_token_expires_at, :datetime

    # AI token tracking
    add_column :users, :ai_tokens_used, :integer, default: 0
    add_column :users, :ai_tokens_limit, :integer, default: 100000
    add_column :users, :ai_tokens_reset_at, :datetime

    # Indexes
    add_index :users, :email, unique: true unless index_exists?(:users, :email)
    add_index :users, :reset_password_token, unique: true
    add_index :users, :discord_id, unique: true
  end
end
