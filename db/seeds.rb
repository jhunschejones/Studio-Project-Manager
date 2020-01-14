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
  user = User.create(name: "Carl Fox", email: ENV['EMAIL_USERNAME'], password: ENV['DEV_PASSWORD'], password_confirmation: ENV['DEV_PASSWORD'], confirmed_at: Time.now.utc)
  user.projects << project
  user.save!

  Link.create(text: "First Link", url: "https://tinyurl.com/umqwsr9", link_for_class: "Project", link_for_id: project.id, user_id: user.id)
end
