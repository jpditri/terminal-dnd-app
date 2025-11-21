# frozen_string_literal: true

class Background < ApplicationRecord
  include Discard::Model

  has_paper_trail

  validates :name, presence: true

  scope :recent, -> { all }
  scope :search_name, -> { all }
  scope :search_description, -> { all }
  scope :search_all, -> { all }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end