require 'test_helper'

# bundle exec ruby -Itest test/jobs/notify_on_track_version_job_test.rb
class NotifyOnTrackVersionJobTest < ActiveJob::TestCase
  describe "when the event no longer exists" do
    before do
      @deleted_track_version_id = track_versions(:one).id
      track_versions(:one).destroy
    end

    test "no notifications are created" do
      assert_no_difference 'Notification.count' do
        NotifyOnTrackVersionJob.perform_now(@deleted_track_version_id)
      end
    end

    test "a message is logged instead of blowing up" do
      expected_warning = "====== Failed to create track version notification ======\nReason: the track version no longer exists"
      test_logger = mock()
      test_logger.stubs(:warn)
      Rails.expects(:logger).times(1).returns(test_logger)
      test_logger.expects(:warn).times(1).with(expected_warning)

      NotifyOnTrackVersionJob.perform_now(@deleted_track_version_id)
    end
  end

  describe "when a notification is generated for an updated track version" do
    test "a notification is created" do
      assert_difference 'Notification.count', 1 do
        NotifyOnTrackVersionJob.perform_now(track_versions(:one).id)
      end
    end

    test "the notification matches the expected format" do
      expected_description = "The version, 'Mix 01', was updated on track 'I Used To Walk Dogs But I Retired'"
      NotifyOnTrackVersionJob.perform_now(track_versions(:one).id, "updated")
      notification = Notification.last

      assert_equal track_versions(:one).track.project_id, notification.project_id
      assert_equal "updated", notification.action
      assert_equal expected_description, notification.description
    end
  end
end
