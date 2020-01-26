class Event < ApplicationRecord
  belongs_to :project
  belongs_to :user

  scope :ordered, -> { order("start_at ASC") }
end
