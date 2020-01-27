class Notification < ApplicationRecord
  belongs_to :project
  belongs_to :notifiable, polymorphic: true
end

#
# Hi user,
#
# Today there were 3 changes on your project "Album 1":
# 1. "mix_01" was added to track "Song One"
# 2. Event "Mixing round 2" was created
# 3. Comment was added to "rough_mix" of track "Song One"
#
# Click here to see the latest changes on your project
#
