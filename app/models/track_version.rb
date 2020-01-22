class TrackVersion < ApplicationRecord
  belongs_to :track
  has_many :links, as: :linkable, dependent: :destroy
  has_many :notes, as: :notable, dependent: :destroy

  scope :ordered, -> { order(:order) }
end
