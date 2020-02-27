class UserMailer < ApplicationMailer
  def daily_notification_email(user_id, project_id, notification_ids)
    @user = User.find(user_id)
    @project = Project.find(project_id)
    @notifications = Notification.where(id: notification_ids)
    mail(to: @user.email, subject: 'Daily project updates')

    @notifications.each { |notification| notification.update!(users_notified: true) }
  end

  def invite_to_project(user_id, project_id, invited_by_id)
    @user = User.find(user_id)
    @invited_by = User.find(invited_by_id)
    @project = Project.find(project_id)

    mail(to: @user.email, subject: "You've been invited to a new project!")
  end
end
