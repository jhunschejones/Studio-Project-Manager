class NotifyOnEventJob < ApplicationJob
  queue_as :default

  def perform(event_id, action="", user_id=nil)
    event = Event.find(event_id)
    user = User.find(user_id || event.user_id)

    notification = Notification.new(
      project_id: event.project_id,
      action: action,
      description: "The '#{event.title}' event was #{action} by #{user.name}"
    )

    event.notifications << notification
    event.save!
  rescue ActiveRecord::RecordNotFound => error
    ::NewRelic::Agent.notice_error(error)
    Rails.logger.warn "====== Failed to create event notification ======\nReason: the user or event no longer exists"
  end
end
