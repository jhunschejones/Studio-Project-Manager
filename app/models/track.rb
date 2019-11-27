class Track < ApplicationRecord
  belongs_to :project
  has_many :revision_notes
  has_many :tracks, optional: true
end
