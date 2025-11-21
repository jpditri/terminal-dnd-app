# frozen_string_literal: true

class AiConversation < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :solo_session, optional: true
  belongs_to :character, optional: true
  has_many :ai_messages, dependent: :destroy

  validates :title, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :solo_session_id_min, -> { all }
  scope :solo_session_id_max, -> { all }
  scope :solo_session_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end