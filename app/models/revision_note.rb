class RevisionNote < ApplicationRecord
  belongs_to :track, :user
end
