require 'test_helper'

# bundle exec ruby -Itest test/jobs/notify_on_comment_job_test.rb
class NotifyOnCommentJobTest < ActiveJob::TestCase
  describe "when the comment no longer exists" do
    before do
      @deleted_comment_id = comments(:one).id
      comments(:one).destroy
    end

    test "no notifications are created" do
      assert_no_difference 'Notification.count' do
        NotifyOnCommentJob.perform_now(@deleted_comment_id)
      end
    end

    test "a message is logged instead of blowing up" do
      expected_warning = "====== Failed to create comment notification ======\nReason: comment, user, or commented-on resource no longer exists"
      test_logger = mock()
      test_logger.stubs(:warn)
      Rails.expects(:logger).times(1).returns(test_logger)
      test_logger.expects(:warn).times(1).with(expected_warning)

      NotifyOnCommentJob.perform_now(@deleted_comment_id)
    end
  end

  describe "when a comment is added for a track version" do
    test "a notification is created" do
      assert_difference 'Notification.count', 1 do
        NotifyOnCommentJob.perform_now(comments(:one).id)
      end
    end

    test "the notification matches the expected format" do
      expected_description = "A comment was added on the 'Mix 01' version of track 'I Used To Walk Dogs But I Retired' by Carl Fox"
      NotifyOnCommentJob.perform_now(comments(:one).id, "added")
      notification = Notification.last

      assert_equal TrackVersion.find(comments(:one).commentable_id).track.project_id, notification.project_id
      assert_equal "added", notification.action
      assert_equal expected_description, notification.description
    end
  end

  describe "when a comment is added for a project" do
    test "a notification is created" do
      assert_difference 'Notification.count', 1 do
        NotifyOnCommentJob.perform_now(comments(:project_comment).id)
      end
    end

    test "the notification matches the expected format" do
      expected_description = "A comment was added on the 'My First Project' project by Carl Fox"
      NotifyOnCommentJob.perform_now(comments(:project_comment).id, "added")
      notification = Notification.last

      assert_equal projects(:one).id, notification.project_id
      assert_equal "added", notification.action
      assert_equal expected_description, notification.description
    end
  end
end
