class TrackVersion < ApplicationRecord
  belongs_to :track
  has_many :revision_notes, dependent: :destroy
end
