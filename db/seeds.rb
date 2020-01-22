# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# path to your application root.
APP_ROOT = File.expand_path('..', __dir__)

FileUtils.chdir APP_ROOT do
  system '. ./tmp/.env'
end

if Project.count == 0
  project = Project.create(title: "My First Project", description: "Lorem ipsum dolor amet umami lumbersexual messenger bag pop-up palo santo, plaid synth fanny pack art party mumblecore semiotics intelligentsia. Retro craft beer thundercats four loko. Gastropub fingerstache occupy trust fund snackwave. Trust fund glossier cronut, kitsch activated charcoal chillwave direct trade. Photo booth williamsburg chambray kinfolk. Green juice godard shabby chic banh mi.")
  user = User.create(name: "Carl Fox", email: ENV['EMAIL_USERNAME'], password: ENV['DEV_PASSWORD'], password_confirmation: ENV['DEV_PASSWORD'], confirmed_at: Time.now.utc, site_role: "site_creator")
  user.projects << project
  user.save!

  link = Link.new(text: "An Important Linked Resource", url: "https://tinyurl.com/umqwsr9", user_id: user.id)
  project.links << link
  link.save!

  track_one = Track.create(title: "Song One", project_id: project.id, order: 1)
  version_one = TrackVersion.create(track_id: track_one.id, name: "Mix 01A", order: 1)
  track_link = Link.new(text: "An Important Linked Resource", url: "https://tinyurl.com/umqwsr9", user_id: user.id)
  track_note = Note.new(body: "Snare needs to be more punchy", user_id: user.id)
  version_one.links << track_link
  version_one.notes << track_note
  version_one.save!

  Track.create(title: "Song Two", project_id: project.id, order: 2)
  TrackVersion.create(track_id: track_one.id, name: "Mix 01B", order: 2)
  TrackVersion.create(track_id: track_one.id, name: "Mix 01C", order: 3)
end
