require 'test_helper'

# bundle exec ruby -Itest test/models/comment_test.rb
class CommentTest < ActiveSupport::TestCase
  describe "notify_project_users" do
    test "enqueues a notification job after create" do
      stubbed_job = mock()
      stubbed_job.stubs(:perform_later)
      NotifyOnCommentJob.expects(:set).times(1).returns(stubbed_job)
      stubbed_job.expects(:perform_later).times(1).with(kind_of(Integer), "added")

      Comment.create(user: users(:one), commentable: track_versions(:one))
    end
  end
end
