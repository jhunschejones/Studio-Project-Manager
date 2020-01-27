class NotifyOnEventJob < ApplicationJob
  queue_as :default

  def perform(event_id, action="")
    event = Event.find(event_id)
    user = User.find(event.user_id)

    notification = Notification.new(
      project_id: event.project_id,
      action: action,
      description: "The '#{event.title}' event was #{action} by #{user.name}"
    )

    event.notifications << notification
    event.save!
  end
end
