class Track < ApplicationRecord
  belongs_to :project
  has_many :revision_notes, dependent: :destroy

  scope :ordered, -> { order(:order) }
end
