class Event < ApplicationRecord
  belongs_to :project
  belongs_to :user
  has_many :notifications, as: :notifiable, dependent: :destroy

  scope :ordered, -> { order("start_at ASC") }

  after_create :notify_project_users

  private

  def notify_project_users
    NotifyOnEventJob.set(wait: 2.minutes).perform_later(id, "added")
  end
end
