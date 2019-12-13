class Project < ApplicationRecord
  has_many_attached :files
  has_and_belongs_to_many :users
  has_many :tracks
  has_many :events
  has_many :comments

  scope :active, -> { where(is_archived: false) }

  def archive!
    self.update!(
      is_archived: true,
      archived_on: Time.now.utc
    )
  end
end
