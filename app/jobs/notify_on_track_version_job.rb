class NotifyOnTrackVersionJob < ApplicationJob
  queue_as :default

  def perform(track_version_id, action="")
    track_version = TrackVersion.find(track_version_id)
    track = track_version.track

    notification = Notification.new(
      project_id: track.project_id,
      action: action,
      description: "A track version, '#{track_version.title}', was #{action} on '#{track.title}'"
    )

    track_version.notifications << notification
    track_version.save!
  end
end
