class Track < ApplicationRecord
  belongs_to :project
  has_many :track_versions, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_rich_text :description

  scope :ordered, -> { order(:order) }
end
