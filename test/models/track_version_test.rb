require 'test_helper'

# bundle exec ruby -Itest test/models/track_version_test.rb
class TrackVersionTest < ActiveSupport::TestCase
  describe "notify_project_users" do
    test "enqueues a notification job after create" do
      stubbed_job = mock()
      stubbed_job.stubs(:perform_later)
      NotifyOnTrackVersionJob.expects(:set).times(1).returns(stubbed_job)
      stubbed_job.expects(:perform_later).times(1).with(kind_of(Integer), "added")

      TrackVersion.create(title: "Mix 02", track: tracks(:one))
    end
  end
end
