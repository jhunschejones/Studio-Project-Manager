require 'test_helper'

# bundle exec ruby -Itest test/models/event_test.rb
class EventTest < ActiveSupport::TestCase
  describe "notify_project_users" do
    test "enqueues a notification job after create" do
      stubbed_job = mock()
      stubbed_job.stubs(:perform_later)
      NotifyOnEventJob.expects(:set).times(1).returns(stubbed_job)
      stubbed_job.expects(:perform_later).times(1).with(kind_of(Integer), "added")

      Event.create(title: "Drum Tracking",
        start_at: Time.now,
        end_at: Time.now + 5.hours,
        project: projects(:one),
        user: users(:one)
      )
    end
  end
end
