class Notification < ApplicationRecord
  belongs_to :project
  belongs_to :notifiable, polymorphic: true

  scope :unsent, -> { where(users_notified: false) }
  scope :sent, -> { where(users_notified: true) }
  scope :recent, -> { order(created_at: :desc).limit(RECENT_COUNT) }

  RECENT_COUNT = 5.freeze

  def self.clean_old
    sent.order(created_at: :desc).offset(RECENT_COUNT).destroy_all
  end
end
