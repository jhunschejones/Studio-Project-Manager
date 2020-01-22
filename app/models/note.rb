class Note < ApplicationRecord
  belongs_to :user, dependent: :destroy
  belongs_to :notable, polymorphic: true
end
