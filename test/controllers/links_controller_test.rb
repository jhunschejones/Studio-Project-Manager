require 'test_helper'

# bundle exec ruby -Itest test/controllers/links_controller_test.rb
class LinksControllerTest < ActionDispatch::IntegrationTest
  ###
  # For project links
  ###
  describe "for project links" do
    describe "#edit" do
      describe "when user is not logged in" do
        test "redirect to login page" do
          get edit_project_link_path(projects(:one), links(:project_link))
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
            get edit_project_link_path(projects(:one), links(:project_link))

            assert_redirected_to projects_path
            follow_redirect!
            assert_equal "You cannot access that project", flash[:notice]
          end
        end

        describe "when user has user_project record" do
          test "renders event page" do
            UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_user")
            get edit_project_link_path(projects(:one), links(:project_link))

            assert_response :success
            assert_select "h2.title", "Edit link"
          end
        end
      end
    end

    describe "#create" do
      describe "when user is not logged in" do
        test "responds with 401 to js request format" do
          post project_links_path(projects(:one), format: :js), params: { link: { text: "My Link Text", url: "url.com" } }
          assert_response :unauthorized
        end

        test "it does not create a link" do
          assert_no_difference 'Link.count' do
            post project_links_path(projects(:one), format: :js), params: { link: { text: "My Link Text", url: "url.com" } }
          end
        end
      end

      describe "when user is logged in" do
        setup do
          sign_in users(:one)
        end

        describe "when user has a user_project record" do
          test "creates a new link" do
            UserProject.create(user_id: users(:one).id, project_id: projects(:one).id)
            assert_difference 'Link.count', 1 do
              post project_links_path(projects(:one), format: :js), params: { link: { text: "My Link Text", url: "url.com" } }
            end
            assert_match "My Link Text", Link.last.text
          end
        end

        describe "when user does not have a user_project record" do
          setup do
            UserProject.where(user_id: users(:one).id).destroy_all
          end

          test "does not create a new link" do
            assert_no_difference 'Link.count' do
              post project_links_path(projects(:one), format: :js), params: { link: { text: "My Link Text", url: "url.com" } }
            end
          end

          test "redirects to projects page with message" do
            post project_links_path(projects(:one), format: :js), params: { link: { text: "My Link Text", url: "url.com" } }
            assert_redirected_to projects_path
            assert_equal "You cannot access that project", flash[:notice]
          end
        end
      end
    end

    describe "#update" do
      describe "when user is not logged in" do
        test "redirect to login page" do
          patch project_link_path(projects(:one), links(:project_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
          assert_redirected_to new_user_session_path
        end

        test "it does not update the link" do
          assert_no_difference 'Link.count' do
            patch project_link_path(projects(:one), links(:project_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
          end
        end
      end

      describe "when user is logged in" do
        setup do
          sign_in users(:one)
        end

        describe "when user does not have a user_project record" do
          setup do
            UserProject.where(user_id: users(:one).id).destroy_all
          end

          test "does not update the link" do
            assert_no_changes -> { Link.find(links(:project_link).id).text } do
              patch project_link_path(projects(:one), links(:project_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
            end
          end

          test "redirects to projects page with message" do
            patch project_link_path(projects(:one), links(:project_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
            assert_redirected_to projects_path
            assert_equal "You cannot access that project", flash[:notice]
          end
        end

        describe "when user has a user_project record" do
          setup do
            UserProject.create(user_id: users(:one).id, project_id: projects(:one).id)
          end

          describe "when the link belongs to the user" do
            setup do
              links(:project_link).update(user_id: users(:one).id)
            end

            test "updates the link" do
              assert_changes -> { Link.find(links(:project_link).id).text } do
                patch project_link_path(projects(:one), links(:project_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
              end
            end

            test "redirects to project edit page" do
              patch project_link_path(projects(:one), links(:project_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
              assert_redirected_to edit_project_path(projects(:one), anchor: "links")
            end
          end

          describe "when the link does not belong to the user" do
            setup do
              links(:project_link).update(user_id: users(:two).id)
            end

            test "does not update the link" do
              assert_no_changes -> { Link.find(links(:project_link).id).text } do
                patch project_link_path(projects(:one), links(:project_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
              end
            end

            test "redirects to projects page with message" do
              patch project_link_path(projects(:one), links(:project_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
              assert_redirected_to project_path(projects(:one))
              assert_equal "You cannot modify that link.", flash[:alert]
            end
          end
        end
      end
    end

    describe "#destroy" do
      describe "when user is not logged in" do
        test "responds with a 401" do
          delete project_link_path(projects(:one), links(:project_link), format: :js)
          assert_response :unauthorized
        end

        test "it does not destroy the link" do
          assert_no_difference 'Link.count' do
            delete project_link_path(projects(:one), links(:project_link), format: :js)
          end
        end
      end

      describe "when user is logged in" do
        setup do
          sign_in users(:one)
        end

        describe "when user does not have a user_project record" do
          setup do
            UserProject.where(user_id: users(:one).id).destroy_all
          end

          test "does not destroy the link" do
            assert_no_difference 'Link.count' do
              delete project_link_path(projects(:one), links(:project_link), format: :js)
            end
          end

          test "redirects to projects page with message" do
            delete project_link_path(projects(:one), links(:project_link), format: :js)
            assert_redirected_to projects_path
            assert_equal "You cannot access that project", flash[:notice]
          end
        end

        describe "when user has a user_project record" do
          setup do
            UserProject.create(user_id: users(:one).id, project_id: projects(:one).id)
          end

          describe "when the link belongs to the user" do
            setup do
              links(:project_link).update(user_id: users(:one).id)
            end

            test "destroys the link" do
              assert_difference 'Link.count', -1 do
                delete project_link_path(projects(:one), links(:project_link), format: :js)
              end
            end
          end

          describe "when the link does not belong to the user" do
            setup do
              links(:project_link).update(user_id: users(:two).id)
            end

            test "does not destroy the link" do
              assert_no_difference 'Link.count' do
                delete project_link_path(projects(:one), links(:project_link), format: :js)
              end
            end

            test "redirects to projects page with message" do
              delete project_link_path(projects(:one), links(:project_link), format: :js)
              assert_redirected_to project_path(projects(:one))
              assert_equal "You cannot modify that link.", flash[:alert]
            end
          end
        end
      end
    end
  end

  ###
  # For track version links
  ###
  describe "for track version links" do
    describe "#edit" do
      describe "when user is not logged in" do
        test "redirect to login page" do
          get edit_project_link_path(projects(:one), links(:track_version_link))
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
            get edit_project_link_path(projects(:one), links(:track_version_link))

            assert_redirected_to projects_path
            follow_redirect!
            assert_equal "You cannot access that project", flash[:notice]
          end
        end

        describe "when user has user_project record" do
          test "renders event page" do
            UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_user")
            get edit_project_link_path(projects(:one), links(:track_version_link))

            assert_response :success
            assert_select "h2.title", "Edit link"
          end
        end
      end
    end

    describe "#create" do
      describe "when user is not logged in" do
        test "responds with 401 to js request format" do
          post project_track_track_version_links_path(projects(:one), tracks(:one), track_versions(:one), format: :js), params: { link: { text: "My Link Text", url: "url.com" } }
          assert_response :unauthorized
        end

        test "it does not create a link" do
          assert_no_difference 'Link.count' do
            post project_track_track_version_links_path(projects(:one), tracks(:one), track_versions(:one), format: :js), params: { link: { text: "My Link Text", url: "url.com" } }
          end
        end
      end

      describe "when user is logged in" do
        setup do
          sign_in users(:one)
        end

        describe "when user has a user_project record" do
          test "creates a new link" do
            UserProject.create(user_id: users(:one).id, project_id: projects(:one).id)
            assert_difference 'Link.count', 1 do
              post project_track_track_version_links_path(projects(:one), tracks(:one), track_versions(:one), format: :js), params: { link: { text: "My Link Text", url: "url.com" } }
            end
            assert_match "My Link Text", Link.last.text
          end
        end

        describe "when user does not have a user_project record" do
          setup do
            UserProject.where(user_id: users(:one).id).destroy_all
          end

          test "does not create a new link" do
            assert_no_difference 'Link.count' do
              post project_track_track_version_links_path(projects(:one), tracks(:one), track_versions(:one), format: :js), params: { link: { text: "My Link Text", url: "url.com" } }
            end
          end

          test "redirects to projects page with message" do
            post project_track_track_version_links_path(projects(:one), tracks(:one), track_versions(:one), format: :js), params: { link: { text: "My Link Text", url: "url.com" } }
            assert_redirected_to projects_path
            assert_equal "You cannot access that project", flash[:notice]
          end
        end
      end
    end

    describe "#update" do
      describe "when user is not logged in" do
        test "redirect to login page" do
          patch project_link_path(projects(:one), links(:track_version_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
          assert_redirected_to new_user_session_path
        end

        test "it does not update the link" do
          assert_no_difference 'Link.count' do
            patch project_link_path(projects(:one), links(:track_version_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
          end
        end
      end

      describe "when user is logged in" do
        setup do
          sign_in users(:one)
        end

        describe "when user does not have a user_project record" do
          setup do
            UserProject.where(user_id: users(:one).id).destroy_all
          end

          test "does not update the link" do
            assert_no_changes -> { Link.find(links(:track_version_link).id).text } do
              patch project_link_path(projects(:one), links(:track_version_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
            end
          end

          test "redirects to projects page with message" do
            patch project_link_path(projects(:one), links(:track_version_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
            assert_redirected_to projects_path
            assert_equal "You cannot access that project", flash[:notice]
          end
        end

        describe "when user has a user_project record" do
          setup do
            UserProject.create(user_id: users(:one).id, project_id: projects(:one).id)
          end

          describe "when the link belongs to the user" do
            setup do
              links(:track_version_link).update(user_id: users(:one).id)
            end

            test "updates the link" do
              assert_changes -> { Link.find(links(:track_version_link).id).text } do
                patch project_link_path(projects(:one), links(:track_version_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
              end
            end

            test "redirects to track version page" do
              patch project_link_path(projects(:one), links(:track_version_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
              assert_redirected_to project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one))
            end
          end

          describe "when the link does not belong to the user" do
            setup do
              links(:track_version_link).update(user_id: users(:two).id)
            end

            test "does not update the link" do
              assert_no_changes -> { Link.find(links(:track_version_link).id).text } do
                patch project_link_path(projects(:one), links(:track_version_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
              end
            end

            test "redirects to projects page with message" do
              patch project_link_path(projects(:one), links(:track_version_link)), params: { link: { text: "My Updated Link Text", url: "new-url.com" } }
              assert_redirected_to project_path(projects(:one))
              assert_equal "You cannot modify that link.", flash[:alert]
            end
          end
        end
      end
    end

    describe "#destroy" do
      describe "when user is not logged in" do
        test "responds with a 401" do
          delete project_link_path(projects(:one), links(:track_version_link), format: :js)
          assert_response :unauthorized
        end

        test "it does not destroy the link" do
          assert_no_difference 'Link.count' do
            delete project_link_path(projects(:one), links(:track_version_link), format: :js)
          end
        end
      end

      describe "when user is logged in" do
        setup do
          sign_in users(:one)
        end

        describe "when user does not have a user_project record" do
          setup do
            UserProject.where(user_id: users(:one).id).destroy_all
          end

          test "does not destroy the link" do
            assert_no_difference 'Link.count' do
              delete project_link_path(projects(:one), links(:track_version_link), format: :js)
            end
          end

          test "redirects to projects page with message" do
            delete project_link_path(projects(:one), links(:track_version_link), format: :js)
            assert_redirected_to projects_path
            assert_equal "You cannot access that project", flash[:notice]
          end
        end

        describe "when user has a user_project record" do
          setup do
            UserProject.create(user_id: users(:one).id, project_id: projects(:one).id)
          end

          describe "when the link belongs to the user" do
            setup do
              links(:track_version_link).update(user_id: users(:one).id)
            end

            test "destroys the link" do
              assert_difference 'Link.count', -1 do
                delete project_link_path(projects(:one), links(:track_version_link), format: :js)
              end
            end
          end

          describe "when the link does not belong to the user" do
            setup do
              links(:track_version_link).update(user_id: users(:two).id)
            end

            test "does not destroy the link" do
              assert_no_difference 'Link.count' do
                delete project_link_path(projects(:one), links(:track_version_link), format: :js)
              end
            end

            test "redirects to projects page with message" do
              delete project_link_path(projects(:one), links(:track_version_link), format: :js)
              assert_redirected_to project_path(projects(:one))
              assert_equal "You cannot modify that link.", flash[:alert]
            end
          end
        end
      end
    end
  end
end
