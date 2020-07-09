require 'test_helper'

# bundle exec ruby -Itest test/jobs/send_daily_notifications_job_test.rb
class SendDailyNotificationsJobTest < ActiveJob::TestCase
  describe "when the project no longer exists" do
    before do
      @deleted_project_id = projects(:one).id
      projects(:one).destroy
    end

    test "no notification emails are sent" do
      SendDailyNotificationsJob.perform_now(@deleted_project_id)
      assert_equal 0, ActionMailer::Base.deliveries.size
    end

    test "a message is logged instead of blowing up" do
      expected_warning = "====== Failed to send daily notifications ======\nReason: project no longer exists"
      test_logger = mock()
      test_logger.stubs(:warn)
      Rails.expects(:logger).times(1).returns(test_logger)
      test_logger.expects(:warn).times(1).with(expected_warning)

      SendDailyNotificationsJob.perform_now(@deleted_project_id)
    end
  end

  describe "when there are no unsent notifications" do
    setup do
      Project.find(projects(:one).id).notifications.unsent.destroy_all
    end

    test "no notification emails are sent" do
      SendDailyNotificationsJob.perform_now(projects(:one).id)

      assert_equal 0, ActionMailer::Base.deliveries.size
    end
  end

  describe "when there are unsent notifications" do
    setup do
      event = events(:one)
      user = users(:one)
      action = "create"

      notification = Notification.new(
        project_id: event.project_id,
        action: action,
        description: "The '#{event.title}' event was #{action} by #{user.name}"
      )

      event.notifications << notification
      event.save!

      assert_equal projects(:one).notifications.unsent.count, 1
    end

    describe "when two users can receive notifications" do
      setup do
        user_projects(:one).update(receive_notifications: true)
      end

      test "the notification email is sent to both users on the project" do
        SendDailyNotificationsJob.perform_now(projects(:one).id)

        assert_equal 2, ActionMailer::Base.deliveries.size
      end

      test "all notifications are marked as sent" do
        SendDailyNotificationsJob.perform_now(projects(:one).id)

        assert_equal 0, Project.find(projects(:one).id).notifications.unsent.size
      end
    end

    describe "when one user cannot receive notifications" do
      setup do
        user_projects(:one).update(receive_notifications: false)
        user_projects(:two).update(receive_notifications: true)
      end

      test "notification email is sent to second user only" do
        SendDailyNotificationsJob.perform_now(projects(:one).id)

        assert_equal 1, ActionMailer::Base.deliveries.size
        assert_equal users(:two).email, ActionMailer::Base.deliveries.first.to.first
      end

      test "all notifications are marked as sent" do
        SendDailyNotificationsJob.perform_now(projects(:one).id)

        assert_equal 0, Project.find(projects(:one).id).notifications.unsent.size
      end
    end

    describe "when no users can receive notifications" do
      setup do
        user_projects(:one).update(receive_notifications: false)
        user_projects(:two).update(receive_notifications: false)
      end

      test "no notification emails are sent" do
        SendDailyNotificationsJob.perform_now(projects(:one).id)

        assert_equal 0, ActionMailer::Base.deliveries.size
      end

      test "all notifications are marked as sent" do
        SendDailyNotificationsJob.perform_now(projects(:one).id)

        assert_equal 0, Project.find(projects(:one).id).notifications.unsent.size
      end
    end
  end
end
