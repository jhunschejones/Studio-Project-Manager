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

  describe "#create" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        post projects_path, params: { project: { title: "A nifty new project!" } }
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user is not site_creator" do
        setup do
          users(:one).update(site_role: "site_user")
        end

        test "no projects are created" do
          assert_no_difference 'Project.count' do
            post projects_path, params: { project: { title: "A nifty new project!" } }
          end
        end

        test "redirects to projects page with message" do
          post projects_path, params: { project: { title: "A nifty new project!" } }
          assert_redirected_to projects_path
          assert_equal "You are not allowed to create new projects", flash[:notice]
        end
      end

      describe "when user is site_creator" do
        setup do
          users(:one).update(site_role: "site_creator")
        end

        test "new project is created" do
          assert_difference 'Project.count', 1 do
            post projects_path, params: { project: { title: "A nifty new project!" } }
          end
          assert_equal "A nifty new project!", Project.last.title
        end

        test "user is redirected to project show page" do
          post projects_path, params: { project: { title: "A nifty new project!" } }
          assert_redirected_to project_path(Project.last)
          follow_redirect!
          assert_select "h1.title", /A nifty new project!/
        end
      end
    end
  end

  describe "#update" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        patch project_path(projects(:one)), params: { project: { title: "A nifty, updated project title!" } }
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user does not have a user_project record" do
        setup do
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
        end

        test "project is not updated" do
          assert_no_changes -> { Project.find(projects(:one).id).title } do
            patch project_path(projects(:one)), params: { project: { title: "A nifty, updated project title!" } }
          end
        end

        test "redirects to projects page" do
          patch project_path(projects(:one)), params: { project: { title: "A nifty, updated project title!" } }
          assert_redirected_to projects_path
          follow_redirect!
          assert_equal "You cannot access that project", flash[:notice]
        end
      end

      describe "when user has a user_project record" do
        setup do
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_user")
        end

        test "project is updated" do
          assert_changes -> { Project.find(projects(:one).id).title } do
            patch project_path(projects(:one)), params: { project: { title: "A nifty, updated project title!" } }
          end
        end

        test "user is recirected to project page" do
          patch project_path(projects(:one)), params: { project: { title: "A nifty, updated project title!" } }
          assert_redirected_to project_path(projects(:one))
          follow_redirect!
          assert_select "h1.title", /A nifty, updated project title!/
        end
      end
    end
  end

  describe "#destroy" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        delete project_path(projects(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user is not project_creator" do
        setup do
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_user")
        end

        test "project is not archived" do
          assert_no_changes -> { Project.find(projects(:one).id).is_archived } do
            delete project_path(projects(:one))
          end
        end

        test "redirects to projects page" do
          delete project_path(projects(:one))
          assert_redirected_to projects_path
          follow_redirect!
          assert_equal "You are not allowed to archive the '#{projects(:one).title}' project", flash[:notice]
        end
      end

      describe "when user has a user_project record" do
        setup do
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_creator")
        end

        test "project is archived" do
          assert_changes -> { Project.find(projects(:one).id).is_archived } do
            delete project_path(projects(:one))
          end
        end

        test "user is recirected to projects page" do
          delete project_path(projects(:one))
          assert_redirected_to projects_path
        end
      end
    end
  end
end
