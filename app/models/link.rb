class Link < ApplicationRecord
  belongs_to :user
  belongs_to :linkable, polymorphic: true
end
