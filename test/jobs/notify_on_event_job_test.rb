require 'test_helper'

# bundle exec ruby -Itest test/jobs/notify_on_event_job_test.rb
class NotifyOnEventJobTest < ActiveJob::TestCase
  describe "when the event no longer exists" do
    before do
      @deleted_event_id = events(:one).id
      events(:one).destroy
    end

    test "no notifications are created" do
      assert_no_difference 'Notification.count' do
        NotifyOnEventJob.perform_now(@deleted_event_id)
      end
    end

    test "a message is logged instead of blowing up" do
      expected_warning = "====== Failed to create event notification ======\nReason: the user or event no longer exists"
      test_logger = mock()
      test_logger.stubs(:warn)
      Rails.expects(:logger).times(1).returns(test_logger)
      test_logger.expects(:warn).times(1).with(expected_warning)

      NotifyOnEventJob.perform_now(@deleted_event_id)
    end
  end

  describe "when a notification is generated for an updated event" do
    test "a notification is created" do
      assert_difference 'Notification.count', 1 do
        NotifyOnEventJob.perform_now(events(:one).id)
      end
    end

    test "the notification matches the expected format" do
      expected_description = "The 'Drum Tracking' event was updated by Carl Fox"
      NotifyOnEventJob.perform_now(events(:one).id, "updated")
      notification = Notification.last

      assert_equal events(:one).project_id, notification.project_id
      assert_equal "updated", notification.action
      assert_equal expected_description, notification.description
    end
  end
end
