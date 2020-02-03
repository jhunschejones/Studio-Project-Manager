require 'test_helper'

# bundle exec ruby -Itest test/controllers/comments_controller_test.rb
class CommentsControllerTest < ActionDispatch::IntegrationTest
  describe "#new" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get new_project_track_track_version_comment_url(projects(:one), tracks(:one), track_versions(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      test "gets the new track_version comment page" do
        sign_in users(:one)
        get new_project_track_track_version_comment_url(projects(:one), tracks(:one), track_versions(:one))
        assert_response :success
        assert_select "h2.title", /Add a comment:/
      end
    end
  end

  describe "#edit" do
    describe "when no user is logged in" do
      test "redirect to login page" do
        get edit_project_comment_url(projects(:one), comments(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      test "gets the edit comment page" do
        sign_in users(:one)
        get edit_project_comment_url(projects(:one), comments(:one))
        assert_response :success
        assert_select "h2.title", /Edit your comment:/
      end
    end
  end

  describe "#create" do
    describe "when no user is logged in" do
      test "no comments are created" do
        assert_no_difference 'Comment.count' do
          post project_track_track_version_comments_path(projects(:one), tracks(:one), track_versions(:one)), params: { comment: { content: "A nifty new comment!" } }
        end
      end

      test "request is redirected to login page" do
        post project_track_track_version_comments_path(projects(:one), tracks(:one), track_versions(:one)), params: { comment: { content: "A nifty new comment!" } }
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      test "creates a new comment" do
        assert_difference 'Comment.count', 1 do
          post project_track_track_version_comments_path(projects(:one), tracks(:one), track_versions(:one)), params: { comment: { content: "A nifty new comment!" } }
        end
        assert_match /.*A nifty new comment!.*/, Comment.last.content.to_plain_text.inspect
      end

      test "redirects to track_version page after creating comment" do
        post project_track_track_version_comments_path(projects(:one), tracks(:one), track_versions(:one)), params: { comment: { content: "A nifty new comment!" } }
        assert_redirected_to project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one))
      end
    end
  end

  describe "#update" do
    describe "when no user is logged in" do
      test "comment is not updated" do
        assert_no_changes -> { Comment.find(comments(:one).id).content.to_plain_text } do
          patch project_comment_path(projects(:one), comments(:one)), params: { comment: { content: "I changed my mind about what this comment should say." } }
        end
      end

      test "request is redirected to login page" do
        patch project_comment_path(projects(:one), comments(:one)), params: { comment: { content: "I changed my mind about what this comment should say." } }
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when comment blongs to user" do
        test "comment is updated" do
          assert_changes -> { Comment.find(comments(:one).id).content.to_plain_text } do
            patch project_comment_path(projects(:one), comments(:one)), params: { comment: { content: "I changed my mind about what this comment should say." } }
          end
        end

        test "user is redirected back to track_version" do
          patch project_comment_path(projects(:one), comments(:one)), params: { comment: { content: "I changed my mind about what this comment should say." } }
          assert_redirected_to project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one))
        end
      end

      describe "when comment does not belong to user" do
        test "comment is not updated" do
          assert_no_changes -> { Comment.find(comments(:one).id).content.to_plain_text } do
            patch project_comment_path(projects(:one), comments(:two)), params: { comment: { content: "I changed my mind about what this comment should say." } }
          end
        end

        test "request is redirected with message" do
          patch project_comment_path(projects(:one), comments(:two)), params: { comment: { content: "I changed my mind about what this comment should say." } }
          assert_redirected_to project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one))
          assert_equal "You cannot modify that comment.", flash[:alert]
        end
      end
    end
  end

  describe "#destroy" do
    describe "when no user is logged in" do
      test "comment is not destroyed" do
        assert_no_difference 'Comment.count' do
          delete project_comment_path(projects(:one), comments(:one))
        end
      end

      test "request is redirect to login page" do
        delete project_comment_path(projects(:one), comments(:one))
        assert_redirected_to new_user_session_path
      end
    end

    describe "when user is logged in" do
      setup do
        sign_in users(:one)
      end

      describe "when comment blongs to user" do
        test "comment is destroyed" do
          assert_difference 'Comment.count', -1 do
            delete project_comment_path(projects(:one), comments(:one))
          end
        end

        test "request is redirected to track_version page" do
          delete project_comment_path(projects(:one), comments(:one))
          assert_redirected_to project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one))
        end
      end

      describe "when comment does not belong to user" do
        test "comment is not destroyed" do
          assert_no_difference 'Comment.count' do
            delete project_comment_path(projects(:one), comments(:two))
          end
        end

        test "request is redirected with message" do
          delete project_comment_path(projects(:one), comments(:two))
          assert_redirected_to project_track_track_version_path(projects(:one), tracks(:one), track_versions(:one))
          assert_equal "You cannot modify that comment.", flash[:alert]
        end
      end
    end
  end
end
