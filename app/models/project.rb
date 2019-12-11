class Project < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :tracks
  has_many :events
  has_many :download_links
  has_many :comments
end
