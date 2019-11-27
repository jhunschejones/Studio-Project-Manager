class DownloadLink < ApplicationRecord
  belongs_to :project
  belongs_to :track, optional: true
end
