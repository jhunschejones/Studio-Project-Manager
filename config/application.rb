require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module StudioProjectManager
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    # Add all files in `/lib` directory to the load path for require statments
    config.autoload_paths += %W(#{Rails.root}/lib)

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Disable field_with_errors wrapper-div on form error
    config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag }
    # automatically include authenticity token in forms
    config.action_view.embed_authenticity_token_in_remote_forms = true
  end
end
