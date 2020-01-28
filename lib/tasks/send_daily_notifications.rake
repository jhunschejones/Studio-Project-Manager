desc "Send daily notification email to project users"
task :send_daily_notifications => [ :environment ] do
  Project.active.each do |project|
    puts "Enqueuing job to send notifications for '#{project.title}'"
    if Rails.env.production?
      SendDailyNotificationsJob.perform_later(project.id)
    else
      SendDailyNotificationsJob.perform_now(project.id)
    end
  end
end
