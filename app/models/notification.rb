# frozen_string_literal: true

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true, optional: true
  belongs_to :user

  validates :notification_type, presence: true
  validates :priority, presence: true
  validates :title, presence: true
  validates :message, presence: true
  validates :user_id, presence: true

  scope :unread, -> { all }
  scope :read, -> { all }
  scope :recent, -> { all }
  scope :for_user, -> { all }
  scope :by_priority, -> { all }
  scope :for_user, ->(user) { where(user: user) }

end