# frozen_string_literal: true

class LootTable < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :user, optional: true
  has_many :loot_table_entries, dependent: :destroy
  has_many :generated_treasures, dependent: :destroy
  belongs_to :user

  validates :name, presence: true
  validates :user_id, presence: true

  scope :srd, -> { all }
  scope :homebrew, -> { all }
  scope :by_type, -> { all }
  scope :for_challenge_rating, -> { all }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end