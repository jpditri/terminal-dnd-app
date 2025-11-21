# frozen_string_literal: true

class Map < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :campaign, optional: true
  has_many :tokens, dependent: :destroy
  belongs_to :campaign

  validates :name, presence: true
  validates :campaign_id, presence: true

  scope :recent, -> { all }
  scope :campaign_id_min, -> { all }
  scope :campaign_id_max, -> { all }
  scope :campaign_id_range, -> { all }
  scope :search_name, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

end