require 'test_helper'

# bundle exec ruby -Itest test/controllers/events_controller_test.rb
class ProjectsControllerTest < ActionDispatch::IntegrationTest
  describe "#show" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get project_event_path(projects(:one), events(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user has no user_project record" do
        test "redirects to projects page" do
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          get project_event_path(projects(:one), events(:one))

          assert_redirected_to projects_path
          follow_redirect!
          assert_equal "You cannot access that project", flash[:notice]
        end
      end

      describe "when user has user_project record" do
        test "renders event page" do
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_user")
          get project_event_path(projects(:one), events(:one))

          assert_response :success
          assert_select "h3.title", /#{events(:one).title}/
        end
      end
    end
  end
end
