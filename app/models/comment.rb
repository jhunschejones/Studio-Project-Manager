class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  has_rich_text :content

  scope :ordered, -> { order("updated_at ASC") }
end
