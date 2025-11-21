# frozen_string_literal: true

class ChatMessage < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :user
  belongs_to :game_session
  belongs_to :recipient, optional: true
  belongs_to :character, optional: true
  has_many :reactions, dependent: :destroy
  belongs_to :user

  validates :content, presence: true
  validates :user_id, presence: true

  scope :public_messages, -> { all }
  scope :for_user, -> { all }
  scope :recent, -> { all }
  scope :before, -> { all }
  scope :search, -> { all }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end