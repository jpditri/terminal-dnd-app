# frozen_string_literal: true

class AiDmSuggestion < ApplicationRecord
  include Discard::Model

  belongs_to :ai_dm_assistant
  belongs_to :game_session, optional: true
  belongs_to :user
  belongs_to :user

  validates :suggestion_type, presence: true
  validates :content, presence: true
  validates :user_id, presence: true

  scope :recent, -> { all }
  scope :accepted, -> { all }
  scope :by_type, -> { all }
  scope :for_session, -> { all }
  scope :for_user, ->(user) { where(user: user) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end