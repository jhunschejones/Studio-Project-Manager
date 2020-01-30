class TrackVersion < ApplicationRecord
  belongs_to :track
  has_many :links, as: :linkable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy
  has_rich_text :description

  after_create :notify_project_users, unless: :skip_notifications

  scope :ordered, -> { order(:order) }

  attr_accessor :skip_notifications

  def notify_project_users
    NotifyOnTrackVersionJob.set(wait: 2.minutes).perform_later(id, "added")
  end
end
