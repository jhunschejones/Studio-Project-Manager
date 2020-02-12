require 'test_helper'

# bundle exec ruby -Itest test/controllers/track_versions_controller_test.rb
class TrackVersionsControllerTest < ActionDispatch::IntegrationTest
  describe "#show" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get project_track_track_version_url(projects(:one), tracks(:one), track_versions(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      test "returns the track version page" do
        sign_in users(:one)
        get project_track_track_version_url(projects(:one), tracks(:one), track_versions(:one))
        assert_response :success
        assert_select "h1.track-version-title", /#{track_versions(:one).title}/
      end
    end
  end

  describe "#edit" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get edit_project_track_track_version_url(projects(:one), tracks(:one), track_versions(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      test "returns the track version edit page" do
        sign_in users(:one)
        get edit_project_track_track_version_url(projects(:one), tracks(:one), track_versions(:one))
        assert_response :success
        assert_select "h2.title", "Edit track version"
      end
    end
  end

  describe "#create" do
    describe "when no user is logged in" do
      test "no track versions are created" do
        assert_no_difference 'TrackVersion.count' do
          post project_track_track_versions_path(projects(:one), tracks(:one), format: :js), params: { track_version: { title: "Mix 02" } }
        end
      end

      test "responds with 401" do
        post project_track_track_versions_path(projects(:one), tracks(:one), format: :js), params: { track_version: { title: "Mix 02" } }
        assert_response :unauthorized
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user cannot manage track version" do
        setup do
          users(:one).update(site_role: "site_user")
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_user")
        end

        test "no track versions are created" do
          assert_no_difference 'TrackVersion.count' do
            post project_track_track_versions_path(projects(:one), tracks(:one), format: :js), params: { track_version: { title: "Mix 02" } }
          end
        end

        test "redirects to project page with message" do
          post project_track_track_versions_path(projects(:one), tracks(:one), format: :js), params: { track_version: { title: "Mix 02" } }
          assert_redirected_to project_path(projects(:one))
          follow_redirect!
          assert_equal "You cannot modify that track version.", flash[:alert]
        end
      end

      describe "when user can manage track version" do
        setup do
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_owner")
        end

        test "creates track version" do
          assert_difference 'TrackVersion.count', 1 do
            post project_track_track_versions_path(projects(:one), tracks(:one), format: :js), params: { track_version: { title: "Mix 02" } }
          end
          assert_match "Mix 02", TrackVersion.last.title
        end
      end
    end
  end

  describe "#update" do
    describe "when no user is logged in" do
      test "track version is not updated" do
        assert_no_changes -> { TrackVersion.find(track_versions(:one).id).title } do
          patch project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one)), params: { track_version: { title: "Mix 02 Updated" } }
        end
      end

      test "redirects to the login page" do
        patch project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one)), params: { track_version: { title: "Mix 02 Updated" } }
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user cannot manage track version" do
        setup do
          users(:one).update(site_role: "site_user")
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_user")
        end

        test "redirects to project page with message" do
          patch project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one)), params: { track_version: { title: "Mix 02 Updated" } }
          assert_redirected_to project_path(projects(:one))
          follow_redirect!
          assert_equal "You cannot modify that track version.", flash[:alert]
        end
      end

      describe "when user can manage track version" do
        setup do
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_owner")
        end

        test "updates track version" do
          assert_changes -> { TrackVersion.find(track_versions(:one).id).title } do
            patch project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one)), params: { track_version: { title: "Mix 02 Updated" } }
          end
          assert_match "Mix 02 Updated", TrackVersion.last.title
        end

        test "redirects to track version page" do
          patch project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one)), params: { track_version: { title: "Mix 02 Updated" } }
          assert_redirected_to project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one))
          follow_redirect!
          assert_select "h1.track-version-title", /Mix 02 Updated/
        end
      end
    end
  end

  describe "#destroy" do
    describe "when no user is logged in" do
      test "no track versions are destroyed" do
        assert_no_difference 'TrackVersion.count' do
          delete project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one), format: :js)
        end
      end

      test "responds with 401" do
        delete project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one), format: :js)
        assert_response :unauthorized
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user cannot manage track version" do
        setup do
          users(:one).update(site_role: "site_user")
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_user")
        end

        test "no track versions are destroyed" do
          assert_no_difference 'TrackVersion.count' do
            delete project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one), format: :js)
          end
        end

        test "redirects to project page with message" do
          delete project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one), format: :js)
          assert_redirected_to project_path(projects(:one))
          follow_redirect!
          assert_equal "You cannot modify that track version.", flash[:alert]
        end
      end

      describe "when user can manage track version" do
        setup do
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_owner")
        end

        test "destroys track version" do
          assert_difference 'TrackVersion.count', -1 do
            delete project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one), format: :js)
          end
        end
      end
    end
  end
end
