# frozen_string_literal: true

class AiMessage < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :ai_conversation

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :ai_conversation_id_min, -> { all }
  scope :ai_conversation_id_max, -> { all }
  scope :ai_conversation_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end