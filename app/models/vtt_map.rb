# frozen_string_literal: true

class VttMap < ApplicationRecord
  belongs_to :vtt_session

  validates :background_url, presence: true
  validates :width, numericality: true

end