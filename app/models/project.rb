class Project < ApplicationRecord
  has_many :user_projects, dependent: :destroy
  has_many :users, through: :user_projects
  has_many :tracks, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :links, as: :linkable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  scope :active, -> { where(is_archived: false) }

  def archive!
    self.update!(
      is_archived: true,
      archived_on: Time.now.utc
    )
  end
end
