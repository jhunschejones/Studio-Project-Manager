class Track < ApplicationRecord
  belongs_to :project
  has_many :track_versions, dependent: :destroy

  scope :ordered, -> { order(:order) }

  def links
    Link.where(link_for_class: 'Track', link_for_id: id)
  end
end
