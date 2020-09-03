class SendDailyNotificationsJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    project = Project.find(project_id)
    unsent_notifications = project.notifications.unsent

    if unsent_notifications.size > 0
      project.users.each do |user|
        user_project = UserProject.find_by(user_id: user.id, project_id: project.id)

        unless user_project.receive_notifications?
          Rails.logger.warn "#{user.name} has notifications disabled for the '#{project.title}' project"
          next unsent_notifications.each { |notification| notification.update!(users_notified: true) }
        end

        notification_email = UserMailer.daily_notification_email(user.id, project.id, unsent_notifications.pluck(:id))
        Rails.env.production? ? notification_email.deliver_later : notification_email.deliver_now
      end
    end

  rescue ActiveRecord::RecordNotFound => error
    ::NewRelic::Agent.notice_error(error)
    Rails.logger.warn "====== Failed to send daily notifications ======\nReason: project no longer exists"
  end
end
