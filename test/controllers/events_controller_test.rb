require 'test_helper'

# bundle exec ruby -Itest test/controllers/events_controller_test.rb
class ProjectsControllerTest < ActionDispatch::IntegrationTest
  describe "#show" do
    describe "when user is not logged in" do
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

  describe "#edit" do
    describe "when user is not logged in" do
      test "redirect to login page" do
        get edit_project_event_path(projects(:one), events(:one))
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
          get edit_project_event_path(projects(:one), events(:one))

          assert_redirected_to projects_path
          follow_redirect!
          assert_equal "You cannot access that project", flash[:notice]
        end
      end

      describe "when user has user_project record" do
        test "renders event page" do
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_user")
          get edit_project_event_path(projects(:one), events(:one))

          assert_response :success
          assert_select "h2.title", "Edit project event"
        end
      end
    end
  end

  describe "#create" do
    describe "when user is not logged in" do
      test "responds with 401 to js request format" do
        post project_events_path(projects(:one), format: :js), params: { event: { title: "A very important event", start_at: Time.now.to_s } }
        assert_response :unauthorized
      end

      test "does not create an event" do
        assert_no_difference 'Event.count' do
          post project_events_path(projects(:one), format: :js), params: { event: { title: "A very important event", start_at: Time.now.to_s } }
        end
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user has a user_project record" do
        test "creates a new event" do
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id)
          assert_difference 'Event.count', 1 do
            post project_events_path(projects(:one), format: :js), params: { event: { title: "A very important event", start_at: Time.now.to_s } }
          end
          assert_match "A very important event", Event.last.title
        end
      end

      describe "when user does not have a user_project record" do
        setup do
          UserProject.where(user_id: users(:one).id).destroy_all
        end

        test "does not create a new event" do
          assert_no_difference 'Event.count' do
            post project_events_path(projects(:one), format: :js), params: { event: { title: "A very important event", start_at: Time.now.to_s } }
          end
        end

        test "redirects to projects page with message" do
          post project_events_path(projects(:one), format: :js), params: { event: { title: "A very important event", start_at: Time.now.to_s } }
          assert_redirected_to projects_path
          assert_equal "You cannot access that project", flash[:notice]
        end
      end
    end
  end

  describe "#update" do
    describe "when user is not logged in" do
      test "does not update event" do
        assert_no_changes -> { Event.find(events(:one).id).title } do
          patch project_event_path(projects(:one), events(:one)), params: { event: { title: "A very updated event" } }
        end
      end

      test "redirect to login page" do
        patch project_event_path(projects(:one), events(:one)), params: { event: { title: "A very updated event" } }
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user has no user_project record" do
        setup do
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
        end

        test "does not update event" do
          assert_no_changes -> { Event.find(events(:one).id).title } do
            patch project_event_path(projects(:one), events(:one)), params: { event: { title: "A very updated event" } }
          end
        end

        test "redirects to projects page" do
          patch project_event_path(projects(:one), events(:one)), params: { event: { title: "A very updated event" } }
          assert_redirected_to projects_path
          follow_redirect!
          assert_equal "You cannot access that project", flash[:notice]
        end
      end

      describe "when user has user_project record" do
        setup do
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_user")
        end

        describe "when user created the event" do
          setup do
            events(:one).update(user_id: users(:one).id)
          end

          test "updates event" do
            assert_changes -> { Event.find(events(:one).id).title } do
              patch project_event_path(projects(:one), events(:one)), params: { event: { title: "A very updated event" } }
            end
          end

          test "redirects to event show page" do
            patch project_event_path(projects(:one), events(:one)), params: { event: { title: "A very updated event" } }
            assert_redirected_to project_event_path(projects(:one), events(:one))
            follow_redirect!
            assert_select "h3.title", "A very updated event"
          end
        end

        describe "when event belongs to another user" do
          setup do
            events(:one).update(user_id: users(:two).id)
            users(:one).update(site_role: "site_user")
          end

          test "does not update event" do
            assert_no_changes -> { Event.find(events(:one).id).title } do
              patch project_event_path(projects(:one), events(:one)), params: { event: { title: "A very updated event" } }
            end
          end

          test "redirects to project page" do
            patch project_event_path(projects(:one), events(:one)), params: { event: { title: "A very updated event" } }
            assert_redirected_to project_path(projects(:one))
            follow_redirect!
            assert_equal "You cannot modify that event.", flash[:alert]
          end
        end
      end
    end
  end

  describe "#destroy" do
    describe "when user is not logged in" do
      test "responds with 401 to js request format" do
        delete project_event_path(projects(:one), events(:one), format: :js)
        assert_response :unauthorized
      end

      test "does not destroy event" do
        assert_no_difference 'Event.count' do
          delete project_event_path(projects(:one), events(:one), format: :js)
        end
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when user has no user_project record" do
        setup do
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
        end

        test "does not delete event" do
          assert_no_difference 'Event.count' do
            delete project_event_path(projects(:one), events(:one), format: :js)
          end
        end

        test "redirects to projects page" do
          delete project_event_path(projects(:one), events(:one), format: :js)
          assert_redirected_to projects_path
          follow_redirect!
          assert_equal "You cannot access that project", flash[:notice]
        end
      end

      describe "when user has user_project record" do
        setup do
          UserProject.where(user_id: users(:one).id, project_id: projects(:one).id).destroy_all
          UserProject.create(user_id: users(:one).id, project_id: projects(:one).id, project_role: "project_user")
        end

        describe "when user created the event" do
          setup do
            events(:one).update(user_id: users(:one).id)
          end

          test "destroys event" do
            assert_difference 'Event.count', -1 do
              delete project_event_path(projects(:one), events(:one), format: :js)
            end
          end
        end

        describe "when event belongs to another user" do
          setup do
            events(:one).update(user_id: users(:two).id)
            users(:one).update(site_role: "site_user")
          end

          test "does not destroy event" do
            assert_no_difference 'Event.count' do
              delete project_event_path(projects(:one), events(:one), format: :js)
            end
          end

          test "redirects to project page" do
            delete project_event_path(projects(:one), events(:one), format: :js)
            assert_redirected_to project_path(projects(:one))
            follow_redirect!
            assert_equal "You cannot modify that event.", flash[:alert]
          end
        end
      end
    end
  end
end
