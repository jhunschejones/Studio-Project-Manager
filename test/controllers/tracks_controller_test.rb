require 'test_helper'

# bundle exec ruby -Itest test/controllers/tracks_controller_test.rb
class TracksControllerTest < ActionDispatch::IntegrationTest
  describe "#show" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get project_track_url(projects(:one), tracks(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      test "returns the track page" do
        sign_in users(:one)
        get project_track_url(projects(:one), tracks(:one))
        assert_response :success
        assert_select "h1.track-title", /#{tracks(:one).title}/
      end
    end
  end

  describe "#edit" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get edit_project_track_url(projects(:one), tracks(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      test "returns the track edit page" do
        sign_in users(:one)
        get edit_project_track_url(projects(:one), tracks(:one))
        assert_response :success
        assert_select 'form input[name="track[title]"][value=?]', tracks(:one).title
      end
    end
  end

  describe "#create" do
    describe "when no user is logged in" do
      test "no tracks are created" do
        assert_no_difference 'Track.count' do
          post project_tracks_path(projects(:one), format: :js), params: { track: { title: "Nickles Is Money Too" } }
        end
      end

      test "responds with 401" do
        post project_tracks_path(projects(:one), format: :js), params: { track: { title: "Nickles Is Money Too" } }
        assert_response :unauthorized
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user does not have a user_project record" do
        setup do
          users(:one).update(site_role: "site_user") # some site-level permissions might work around user_project restriction
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
        end

        test "no tracks are created" do
          assert_no_difference 'Track.count' do
            post project_tracks_path(projects(:one), format: :js), params: { track: { title: "Nickles Is Money Too" } }
          end
        end

        test "redirects to projects page with message" do
          post project_tracks_path(projects(:one), format: :js), params: { track: { title: "Nickles Is Money Too" } }
          assert_redirected_to projects_path
          follow_redirect!
          assert_equal "You cannot access that project", flash[:notice]
        end
      end

      describe "when user has a user_project record" do
        setup do
          users(:one).update(site_role: "site_user") # some site-level permissions might work around user_project restriction
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_owner")
        end

        test "creates a track" do
          assert_difference 'Track.count', 1 do
            post project_tracks_path(projects(:one), format: :js), params: { track: { title: "Nickles Is Money Too" } }
          end
          assert_match "Nickles Is Money Too", Track.last.title
        end
      end
    end
  end

  describe "#update" do
    describe "when no user is logged in" do
      test "no tracks are updated" do
        assert_no_changes -> { Track.find(tracks(:one).id).title } do
          patch project_track_path(projects(:one), tracks(:one)), params: { track: { title: "Nickles Are Money Too" } }
        end
      end

      test "redirects to the login page" do
        patch project_track_path(projects(:one), tracks(:one)), params: { track: { title: "Nickles Are Money Too" } }
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user does not have a user_project record" do
        setup do
          users(:one).update(site_role: "site_user") # some site-level permissions might work around user_project restriction
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
        end

        test "no tracks are updated" do
          assert_no_changes -> { Track.find(tracks(:one).id).title } do
            patch project_track_path(projects(:one), tracks(:one)), params: { track: { title: "Nickles Are Money Too" } }
          end
        end

        test "redirects to projects page with message" do
          patch project_track_path(projects(:one), tracks(:one)), params: { track: { title: "Nickles Are Money Too" } }
          assert_redirected_to projects_path
          follow_redirect!
          assert_equal "You cannot access that project", flash[:notice]
        end
      end

      describe "when user has a user_project record" do
        setup do
          users(:one).update(site_role: "site_user") # some site-level permissions might work around user_project restriction
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_owner")
        end

        test "updates a track" do
          assert_changes -> { Track.find(tracks(:one).id).title } do
            patch project_track_path(projects(:one), tracks(:one)), params: { track: { title: "Nickles Are Money Too" } }
          end
          assert_match "Nickles Are Money Too", Track.find(tracks(:one).id).title
        end

        test "redirects to track page" do
          patch project_track_path(projects(:one), tracks(:one)), params: { track: { title: "Nickles Are Money Too" } }
          assert_redirected_to project_track_path(projects(:one), tracks(:one))
          follow_redirect!
          assert_select "h1.track-title", /#{Track.find(tracks(:one).id).title}/
        end
      end
    end
  end

  describe "#destroy" do
    describe "when no user is logged in" do
      describe "format js" do
        test "no tracks are destroyed" do
          assert_no_difference 'Track.count' do
            delete project_track_path(projects(:one), tracks(:one), format: :js)
          end
        end

        test "responds with 401" do
          delete project_track_path(projects(:one), tracks(:one), format: :js)
          assert_response :unauthorized
        end
      end

      describe "format html" do
        test "no tracks are destroyed" do
          assert_no_difference 'Track.count' do
            delete project_track_path(projects(:one), tracks(:one))
          end
        end

        test "redirects to the login page" do
          delete project_track_path(projects(:one), tracks(:one))
          assert_redirected_to new_user_session_path
        end
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user cannot delete tracks" do
        setup do
          users(:one).update(site_role: "site_user")
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_user")
        end

        test "no tracks are destroyed" do
          # format.js
          assert_no_difference 'Track.count' do
            delete project_track_path(projects(:one), tracks(:one), format: :js)
          end

          # format.html
          assert_no_difference 'Track.count' do
            delete project_track_path(projects(:one), tracks(:one))
          end
        end

        test "redirects to project page with message" do
          delete project_track_path(projects(:one), tracks(:one), format: :js)
          assert_redirected_to project_path(projects(:one))
          follow_redirect!
          assert_equal "You cannot delete tracks.", flash[:alert]
        end
      end

      describe "when user can delete tracks" do
        setup do
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_owner")
        end

        describe "format js" do
          test "destroys track" do
            assert_difference 'Track.count', -1 do
              delete project_track_path(projects(:one), tracks(:one), format: :js)
            end
          end
        end

        describe "format html" do
          test "destroys track" do
            assert_difference 'Track.count', -1 do
              delete project_track_path(projects(:one), tracks(:one))
            end
          end

          test "redirects to project page" do
            delete project_track_path(projects(:one), tracks(:one))
            assert_redirected_to project_path(projects(:one))
          end
        end
      end
    end
  end
end
