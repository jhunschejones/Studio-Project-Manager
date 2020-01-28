desc "Remove old notifications"
task :clean_old_notifications => [ :environment ] do
  Notification.clean_old
end
