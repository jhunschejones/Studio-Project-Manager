class Event < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :destroy

  after_create :notify_project_users, unless: :skip_notifications

  scope :ordered, -> { order("start_at ASC") }

  attr_accessor :skip_notifications

  private

  def notify_project_users
    NotifyOnEventJob.set(wait: 2.minutes).perform_later(id, "added")
  end
end
