class NotifyOnTrackVersionJob < ApplicationJob
  queue_as :default

  def perform(track_version_id, action="")
    track_version = TrackVersion.find(track_version_id)
    track = track_version.track

    notification = Notification.new(
      project_id: track.project_id,
      action: action,
      description: "The version, '#{track_version.title}', was #{action} on track '#{track.title}'"
    )

    track_version.notifications << notification
    track_version.save!
  rescue ActiveRecord::RecordNotFound => error
    ::NewRelic::Agent.notice_error(error)
    Rails.logger.warn "====== Failed to create track version notification ======\nReason: the track version no longer exists"
  end
end
