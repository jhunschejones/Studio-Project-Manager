class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true
  has_many :notifications, as: :notifiable, dependent: :destroy

  has_rich_text :content

  after_create :notify_project_users, unless: :skip_notifications

  scope :ordered, -> { order("updated_at ASC") }

  attr_accessor :skip_notifications

  private

  def notify_project_users
    NotifyOnCommentJob.set(wait: 2.minutes).perform_later(id, "added")
  end
end
