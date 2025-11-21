# frozen_string_literal: true

class GeneratedEncounter < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :encounter_template

  validates :name, presence: true

  scope :active, -> { all }
  scope :recent, -> { all }
  scope :encounter_template_id_min, -> { all }
  scope :encounter_template_id_max, -> { all }
  scope :encounter_template_id_range, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end