require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

require "carrierwave"
require "carrierwave/orm/activerecord"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# 例外追加
require_relative '../lib/exceptions.rb'

module Portfolio
  class Application < Rails::Application
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    # Don't generate system test files.
    config.generators.system_tests = nil

    # carrierwave
    config.enable_dependency_loading = true
    # config.paths.add 'lib', eager_load: true
    # config.autoload_paths += Dir[Rails.root.join('app', 'uploaders')]

    config.time_zone = "Asia/Tokyo"
    config.active_record.default_timezone = :local

    config.i18n.default_locale = :ja

    config.action_view.field_error_proc = proc do |html_tag, _instance|
      html_tag.to_s.html_safe
    end

    # SMTP settings for Gmail
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address:               "smtp.gmail.com",
      port:      	           587,
      domain:                "smtp.gmail.com",
      user_name:             ENV["MAIL_FROM_ADDRESS"],
      password:              Rails.application.credentials.gmail_app_password,
      authentication:        "plain",
      enable_starttls_auto:  true
    }

    config.webpacker.check_yarn_integrity = false
  end
end
