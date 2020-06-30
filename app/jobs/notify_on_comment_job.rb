class NotifyOnCommentJob < ApplicationJob
  queue_as :default

  def perform(comment_id, action="")
    comment = Comment.find(comment_id)
    notification =
      if comment.commentable_type == "TrackVersion"
        notification_for_track_version(comment, action)
      elsif comment.commentable_type == "Project"
        notification_for_project(comment, action)
      else
        raise "Unrecognized comment type"
      end

    comment.notifications << notification
    comment.save!
  rescue ActiveRecord::RecordNotFound => error
    ::NewRelic::Agent.notice_error(error)
    Rails.logger.warn "====== Failed to create comment notification ======\nReason: comment, user, or commented-on resource no longer exists"
  end

  private

  def notification_for_project(comment, action)
    user = User.find(comment.user_id)
    project = Project.find(comment.commentable_id)

    Notification.new(
      project_id: project.id,
      action: action,
      description: "A comment was #{action} on the '#{project.title}' project by #{user.name}"
    )
  end

  def notification_for_track_version(comment, action)
    user = User.find(comment.user_id)
    track_version = TrackVersion.find(comment.commentable_id)
    track = track_version.track
    project = track.project

    Notification.new(
      project_id: project.id,
      action: action,
      description: "A comment was #{action} on the '#{track_version.title}' version of track '#{track.title}' by #{user.name}"
    )
  end
end
