# frozen_string_literal: true

class SessionRecap < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :game_session
  belongs_to :generated_by_user, optional: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :game_session_id_min, -> { all }
  scope :game_session_id_max, -> { all }
  scope :game_session_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end