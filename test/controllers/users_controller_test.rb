require 'test_helper'

# bundle exec ruby -Itest test/controllers/users_controller_test.rb
class UsersControllerTest < ActionDispatch::IntegrationTest
  describe "#show" do
    describe "when user is not logged in" do
      test "redirect to login page" do
        get user_url(users(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user tries to access page for another user" do
        test "redirects with message" do
          get user_url(users(:two))
          assert_redirected_to user_path(users(:one))
          assert_equal "You cannot view other user's profiles.", flash[:alert]
        end
      end

      describe "when user accesses page for themselves" do
        test "returns the user page" do
          get user_url(users(:one))
          assert_response :success
          assert_select "h1.user-title", "My account"
        end
      end
    end
  end

  describe "#add_to_project" do
    describe "when user is not logged in" do
      test "responds with 401" do
        post project_add_user_path(projects(:one), users(:one), format: :js), params: { user: { email: "peter@dafox.com" } }
        assert_response :unauthorized
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user doesn't exist" do
        test "a new user is created" do
          assert_difference 'User.count', 1 do
            post project_add_user_path(projects(:one), users(:one), format: :js), params: { user: { email: "peter@dafox.com" } }
          end
          assert_equal "peter@dafox.com", User.last.email
        end

        test "the new user is invited to the app" do
          assert_enqueued_jobs 0
          assert_enqueued_jobs 1 do
            post project_add_user_path(projects(:one), users(:one), format: :js), params: { user: { email: "peter@dafox.com" } }
          end

          assert_equal "peter@dafox.com", User.last.email
          assert User.last.invitation_token
        end

        test "the new user is added to the project" do
          post project_add_user_path(projects(:one), users(:one), format: :js), params: { user: { email: "peter@dafox.com" } }
          assert_equal "peter@dafox.com", User.last.email
          assert_equal projects(:one).id, User.last.projects.first.id
        end
      end

      describe "when user exists" do
        test "the user is not re-invited to the app" do
          post project_add_user_path(projects(:one), users(:two), format: :js), params: { user: { email: users(:two).email } }
          refute User.find(users(:two).id).invitation_token
        end

        describe "when user is already on the project" do
          test "the user is not added a second time" do
            assert_no_difference "UserProject.where(user_id: #{users(:two).id}).count" do
              post project_add_user_path(projects(:one), users(:two), format: :js), params: { user: { email: users(:two).email } }
            end
          end

          test "no invitation email is sent" do
            assert_enqueued_jobs 0
            assert_enqueued_jobs 0 do
              post project_add_user_path(projects(:one), users(:two), format: :js), params: { user: { email: users(:two).email } }
            end
          end
        end

        describe "when user is not on the project" do
          setup do
            UserProject.where(user_id: users(:two).id).destroy_all
          end

          test "the user is added to the project" do
            assert_difference "UserProject.where(user_id: #{users(:two).id}).count", 1 do
              post project_add_user_path(projects(:one), users(:two), format: :js), params: { user: { email: users(:two).email } }
            end
          end

          test "the user is sent a project invitation email" do
            assert_enqueued_jobs 0
            assert_enqueued_jobs 1 do
              post project_add_user_path(projects(:one), users(:two), format: :js), params: { user: { email: users(:two).email } }
            end
          end
        end
      end
    end
  end

  describe "#remove_from_project" do
    describe "when user is not logged in" do
      test "responds with 401" do
        delete project_remove_user_path(projects(:one), users(:two), format: :js), params: { user_id: users(:one).id, project_id: projects(:one).id }
        assert_response :unauthorized
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when UserProject record can't be found" do
        setup do
          UserProject.where(user_id: users(:two).id, project_id: projects(:one).id).destroy_all
        end

        test "no users are deleted" do
          assert_no_difference 'UserProject.count' do
            delete project_remove_user_path(projects(:one), users(:two), format: :js), params: { user_id: users(:two).id, project_id: projects(:one).id }
          end
        end

        test "redirects with message" do
          delete project_remove_user_path(projects(:one), users(:two), format: :js), params: { user_id: users(:two).id, project_id: projects(:one).id }
          assert_redirected_to edit_project_path(projects(:one), anchor: "users")
          assert_equal "User not found on this project", flash[:notice]
        end
      end

      describe "when target user is not a project owner" do
        setup do
          UserProject.where(user_id: users(:two).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:two).id, project_id: projects(:one).id, project_role: UserProject::PROJECT_OWNER)
        end

        test "the user is removed from the project" do
          assert_difference 'UserProject.count', -1 do
            delete project_remove_user_path(projects(:one), users(:two), format: :js), params: { user_id: users(:two).id, project_id: projects(:one).id }
          end
        end
      end

      describe "when target user is a project owner" do
        setup do
          UserProject.where(user_id: users(:two).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:two).id, project_id: projects(:one).id, project_role: UserProject::PROJECT_OWNER)
        end

        describe "when user can manage project owners" do
          test "the user is removed from the project" do
            assert_difference 'UserProject.count', -1 do
              delete project_remove_user_path(projects(:one), users(:two), format: :js), params: { user_id: users(:two).id, project_id: projects(:one).id }
            end
          end
        end

        describe "when user can't manage project owners" do
          setup do
            UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
            UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: UserProject::PROJECT_USER)
            users(:one).update(site_role: User::SITE_USER)
          end

          test "the user is not removed from the project" do
            assert_no_difference 'UserProject.count' do
              delete project_remove_user_path(projects(:one), users(:two), format: :js), params: { user_id: users(:two).id, project_id: projects(:one).id }
            end
          end

          test "redirects with message" do
            delete project_remove_user_path(projects(:one), users(:two), format: :js), params: { user_id: users(:two).id, project_id: projects(:one).id }
            assert_redirected_to edit_project_path(projects(:one), anchor: "users")
            assert_equal "You cannot remove a project owner", flash[:notice]
          end
        end
      end
    end
  end

  describe "#update_preferences" do
    describe "when user is not logged in" do
      test "responds with 401" do
        patch project_update_preferences_path(projects(:one), users(:two), format: :js), params: { user_id: users(:one).id, project_id: projects(:one).id, button: "Subscribe" }
        assert_response :unauthorized
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when target user is current user" do
        setup do
          @user_project = UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).first
        end

        describe "when updating email notification prefrences" do
          test "user can be set to receive notification emails" do
            @user_project.update!(receive_notifications: false)
            patch project_update_preferences_path(projects(:one), users(:one), format: :js), params: { user_id: users(:one).id, project_id: projects(:one).id, button: "Subscribe" }
            assert @user_project.reload.receive_notifications?
          end

          test "user can be set to not receive notification emails" do
            @user_project.update!(receive_notifications: true)
            patch project_update_preferences_path(projects(:one), users(:one), format: :js), params: { user_id: users(:one).id, project_id: projects(:one).id, button: "Unsubscribe" }
            refute @user_project.reload.receive_notifications?
          end
        end
      end

      describe "when target user is not current user" do
        setup do
          UserProject.where(user_id: users(:two).id, project_id: projects(:one).id).first.update!(receive_notifications: false)
        end

        test "prefrences are not updated" do
          assert_no_changes -> { UserProject.where(user_id: users(:two).id, project_id: projects(:one).id).first.receive_notifications } do
            patch project_update_preferences_path(projects(:one), users(:two), format: :js), params: { user_id: users(:one).id, project_id: projects(:one).id, button: "Subscribe" }
          end
        end

        test "redirects with message" do
          patch project_update_preferences_path(projects(:one), users(:two), format: :js), params: { user_id: users(:one).id, project_id: projects(:one).id, button: "Subscribe" }
          assert_redirected_to edit_user_registration_path
          assert_equal "You cannot modify another user's prefrences.", flash[:alert]
        end
      end
    end
  end
end
