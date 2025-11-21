# frozen_string_literal: true

class QuestObjective < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :quest_log

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :quest_log_id_min, -> { all }
  scope :quest_log_id_max, -> { all }
  scope :quest_log_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end