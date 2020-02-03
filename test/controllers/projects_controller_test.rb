require 'test_helper'

# bundle exec ruby -Itest test/controllers/projects_controller_test.rb
class ProjectsControllerTest < ActionDispatch::IntegrationTest
  describe "#index" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get projects_path
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      test "shows active projects" do
        get projects_path
        assert_response :success
        assert_select "div.all-projects", /#{projects(:one).title}/
      end

      test "does not show archived projects" do
        projects(:two).update(is_archived: true)
        get projects_path
        assert_response :success
        assert_select "div.all-projects", count: 0, text: /#{projects(:two).title}/
      end

      describe "when user is site_user" do
        test "does not show button to create new projects" do
          users(:one).update(site_role: "site_user")
          get projects_path
          assert_response :success
          assert_select "div.all-projects", count: 0, text: /New project/
        end
      end

      describe "when user is site_creator" do
        test "shows button to create new projects" do
          users(:one).update(site_role: "site_creator")
          get projects_path
          assert_response :success
          assert_select "div.all-projects", /New project/
        end
      end

      describe "when user is site_admin" do
        setup do
          users(:one).update(site_role: "site_admin")
        end

        test "shows button to create new projects" do
          get projects_path
          assert_response :success
          assert_select "div.all-projects", /New project/
        end

        test "shows archived projects" do
          projects(:two).update(is_archived: true)
          get projects_path
          assert_response :success
          assert_select "div.all-projects", /#{projects(:two).title}/
        end
      end
    end
  end

  describe "#show" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get project_path(projects(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user is site_user" do
        setup do
          users(:one).update(site_role: "site_user")
        end

        describe "when user has a user_project record" do
          test "shows project page" do
            UserProject.create(user_id: users(:one).id, project_id: projects(:one).id)
            get project_path(projects(:one))
            assert_response :success
            assert_select ".project-title", /#{projects(:one).title}/
          end
        end

        describe "when user does not have a user_project record" do
          test "redirects to projects page with message" do
            UserProject.where(user_id: users(:one).id).destroy_all
            get project_path(projects(:one))
            assert_redirected_to projects_path
            assert_equal "You cannot access that project", flash[:notice]
          end
        end
      end

      describe "when user is site_admin" do
        describe "when user does not have a user_project record" do
          test "shows project page" do
            UserProject.where(user_id: users(:one).id).destroy_all
            users(:one).update(site_role: "site_admin")

            get project_path(projects(:one))
            assert_response :success
            assert_select ".project-title", /#{projects(:one).title}/
          end
        end
      end
    end
  end

  describe "#new" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get new_project_path
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user is site_creator" do
        test "renders new project page" do
          users(:one).update(site_role: "site_creator")
          get new_project_path
          assert_response :success
          assert_select "h2", /New project/
        end
      end

      describe "when user is site_admin" do
        test "renders new project page" do
          users(:one).update(site_role: "site_admin")
          get new_project_path
          assert_response :success
          assert_select "h2", /New project/
        end
      end

      describe "when user is site_user" do
        test "redirects to projects page with message" do
          users(:one).update(site_role: "site_user")
          get new_project_path
          assert_redirected_to projects_path
          assert_equal "You are not allowed to create new projects", flash[:notice]
        end
      end
    end
  end
end
