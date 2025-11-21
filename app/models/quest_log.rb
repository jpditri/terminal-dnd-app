# frozen_string_literal: true

class QuestLog < ApplicationRecord
  include Discard::Model

  has_paper_trail

  belongs_to :campaign
  belongs_to :character, optional: true
  belongs_to :template, optional: true
  belongs_to :parent_quest, optional: true
  has_many :quest_objectives, dependent: :destroy
  has_many :child_quests, dependent: :nullify
  has_many :quests_in_chain

  # Validations
  validates :title, presence: true
  validates :status, presence: true, inclusion: {
    in: %w[available active completed failed],
    message: "%{value} is not a valid status"
  }
  validates :quest_type, inclusion: {
    in: %w[rescue investigation delivery combat exploration],
    message: "%{value} is not a valid quest type",
    allow_nil: true
  }
  validates :presentation_count, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :escalation_level, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 5
  }, allow_nil: true

  # Consequence-related validations
  validate :consequence_fields_consistency
  validate :resolution_status_consistency

  # Callbacks
  before_validation :set_default_status, on: :create
  before_validation :initialize_consequence_fields, on: :create
  after_update :log_consequence_application, if: :saved_change_to_consequence_applied?
  after_update :log_auto_resolution, if: :saved_change_to_resolution_type?

  # Scopes
  scope :active, -> { all }
  scope :recent, -> { all }
  scope :campaign_id_min, -> { all }
  scope :campaign_id_max, -> { all }
  scope :campaign_id_range, -> { all }
  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  scope :with_consequences, -> { where(consequence_applied: true) }
  scope :auto_resolved, -> { where.not(resolution_type: nil) }
  scope :ignored, -> { where('presentation_count >= ?', 3) }
  default_scope -> { kept }
  scope :with_discarded, -> { unscope(where: :discarded_at) }
  scope :discarded, -> { with_discarded.discarded }

  # Consequence manager helper
  def consequence_manager
    @consequence_manager ||= Quest::ConsequenceManager.new(self)
  end

  private

  def set_default_status
    self.status ||= 'available'
  end

  def initialize_consequence_fields
    self.presentation_count ||= 0
    self.consequence_applied ||= false
    self.escalation_level ||= 0
  end

  def consequence_fields_consistency
    # If consequence_applied is true, escalation_level should be > 0
    if consequence_applied? && (escalation_level.nil? || escalation_level.zero?)
      errors.add(:escalation_level, 'must be greater than 0 when consequences are applied')
    end

    # If escalation_level > 0, consequence_applied should be true
    if escalation_level.present? && escalation_level.positive? && !consequence_applied?
      errors.add(:consequence_applied, 'must be true when escalation_level is set')
    end
  end

  def resolution_status_consistency
    # If resolution_type is set, status should be completed or failed
    if resolution_type.present? && !%w[completed failed].include?(status)
      errors.add(:status, 'must be completed or failed when quest has auto-resolved')
    end

    # If status is completed/failed and resolution_type is set, completed_at should be set
    if %w[completed failed].include?(status) && resolution_type.present? && completed_at.nil?
      errors.add(:completed_at, 'must be set when quest has auto-resolved')
    end
  end

  def log_consequence_application
    return unless consequence_applied?

    Rails.logger.info "Quest #{id} ('#{title}'): Consequences applied at escalation level #{escalation_level}"
  end

  def log_auto_resolution
    return unless resolution_type.present?

    Rails.logger.info "Quest #{id} ('#{title}'): Auto-resolved with type '#{resolution_type}' and status '#{status}'"
  end
end