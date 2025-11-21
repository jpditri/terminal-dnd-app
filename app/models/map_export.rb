# frozen_string_literal: true

# Tracks exported dungeon maps
class MapExport < ApplicationRecord
  has_paper_trail

  # Relationships
  belongs_to :dungeon_map
  belongs_to :user

  # Validations
  validates :export_format, presence: true, inclusion: { in: %w[json ascii svg png] }
  validates :filename, presence: true

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :not_expired, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }
  scope :by_format, ->(format) { where(export_format: format) }

  # Check if export has expired
  def expired?
    expires_at.present? && expires_at <= Time.current
  end

  # Get download URL
  def download_url
    return nil if expired?

    # In production, generate signed URL
    "/exports/maps/#{filename}"
  end

  # Delete file when record is destroyed
  after_destroy :cleanup_file

  private

  def cleanup_file
    return unless file_path.present? && File.exist?(file_path)

    File.delete(file_path)
  rescue StandardError => e
    Rails.logger.error("Failed to delete export file: #{e.message}")
  end
end
