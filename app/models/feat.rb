# frozen_string_literal: true

class Feat < ApplicationRecord
  has_many :character_feats, dependent: :destroy
  has_many :characters, through: :character_feats

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  validates :source, presence: true

  scope :srd, -> { all }
  scope :alphabetical, -> { all }

end