require 'test_helper'

# bundle exec ruby -Itest test/models/project_test.rb
class ProjectTest < ActiveSupport::TestCase
  describe "archive!" do
    test "it does not delete the project" do
      assert_no_difference 'Project.count' do
        projects(:one).archive!
      end
    end

    test "it updates project is_archived attribute" do
      projects(:one).archive!
      assert_equal true, Project.find(projects(:one).id).is_archived
    end

    test "it updates project archived_on attribute" do
      freeze_time do
        projects(:one).archive!
        assert_equal Time.now, Project.find(projects(:one).id).archived_on
      end
    end
  end
end
