class Project < ApplicationRecord
  has_and_belongs_to_many :users
  has_many :tracks, :events, :download_links, :comments
end
