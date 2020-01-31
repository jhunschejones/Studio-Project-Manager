class Link < ApplicationRecord
  belongs_to :user
  belongs_to :linkable, polymorphic: true

  def linked_resource
    linkable_type.constantize.find(linkable_id)
  end
end
