require 'test_helper'

# bundle exec ruby -Itest test/models/notification_test.rb
class NotificationTest < ActiveSupport::TestCase
  describe "#clean_old" do
    test "deletes all sent notifications except the 5 most recent" do
      10.times do |i|
        Notification.create!(
          project: projects(:one),
          notifiable: track_versions(:one),
          users_notified: true
        )
      end

      assert_equal 10, Notification.count
      assert_difference 'Notification.count', -5 do
        Notification.clean_old
      end
    end

    test "does not delete unsent notifications" do
      10.times do |i|
        Notification.create!(
          project: projects(:one),
          notifiable: track_versions(:one)
        )
      end

      assert_equal 10, Notification.count

      assert_no_difference 'Notification.count' do
        Notification.clean_old
      end
    end
  end
end
