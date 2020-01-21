class RevisionNote < ApplicationRecord
  belongs_to :track_version
  belongs_to :user
end
