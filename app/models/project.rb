class Project < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :tracks, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :comments, dependent: :destroy
  before_destroy :remove_links, prepend: true

  scope :active, -> { where(is_archived: false) }

  def archive!
    self.update!(
      is_archived: true,
      archived_on: Time.now.utc
    )
  end

  def links
    Link.where(link_for_class: 'Project', link_for_id: id)
  end

  private

  def remove_links
    links = Link.where(link_for_class: "Project", link_for_id: id).destroy_all
  end
end
