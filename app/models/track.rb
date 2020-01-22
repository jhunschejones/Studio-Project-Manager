class Track < ApplicationRecord
  belongs_to :project
  has_many :track_versions, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy

  scope :ordered, -> { order(:order) }
end
