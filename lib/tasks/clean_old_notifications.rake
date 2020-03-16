desc "Remove old notifications"
task :clean_old_notifications => [ :environment ] do
  puts "Cleaning sent notifications"
  Notification.clean_old
end
