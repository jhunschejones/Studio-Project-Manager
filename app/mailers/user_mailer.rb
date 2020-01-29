class UserMailer < ApplicationMailer
  def daily_notification_email(user_id, project_id, notification_ids)
    @user = User.find(user_id)
    @project = Project.find(project_id)
    @notifications = Notification.where(id: notification_ids)
    mail(to: @user.email, subject: 'Daily project updates')

    @notifications.each { |notification| notification.update!(users_notified: true) }
  end
end
