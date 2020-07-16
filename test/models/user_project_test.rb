require 'test_helper'

# bundle exec ruby -Itest test/models/user_project_test.rb
class UserProjectTest < ActiveSupport::TestCase
  test "sets default role as project_user" do
    user_project = UserProject.create!(user: users(:two), project: projects(:new_project))
    assert_equal "project_user", user_project.project_role
  end

  describe "validations" do
    test "requires valid project_role" do
      expected_error_message = {:project_role=>["not included in '[\"project_owner\", \"project_user\"]'"]}
      user_project = UserProject.new(user: users(:two), project: projects(:new_project), project_role: "robot_leader")
      user_project.validate
      assert_equal expected_error_message, user_project.errors.messages
    end

    test "prevents invalid project_role" do
      assert_raises ActiveRecord::RecordInvalid do
        UserProject.create!(user: users(:two), project: projects(:new_project), project_role: "robot_leader")
      end
    end
  end
end
