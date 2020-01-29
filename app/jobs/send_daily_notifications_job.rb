class SendDailyNotificationsJob < ApplicationJob
  queue_as :default

  def perform(project_id)
    project = Project.find(project_id)
    unsent_notifications = project.notifications.unsent

    if unsent_notifications.size > 0
      project.users.each do |user|
        user_project = UserProject.where(user_id: user.id, project_id: project.id).first
        if user_project.receive_notifications?
          if Rails.env.production?
            UserMailer.daily_notification_email(user.id, project.id, unsent_notifications.pluck(:id)).deliver_later
          else
            UserMailer.daily_notification_email(user.id, project.id, unsent_notifications.pluck(:id)).deliver_now
          end
        else
          puts "#{user.name} has notifications disabled for the '#{project.title}' project"
          unsent_notifications.each { |notification| notification.update!(users_notified: true) }
        end
      end
    end
  end
end
