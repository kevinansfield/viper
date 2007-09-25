# Be sure to restart your web server when you modify this file.

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '1.2.3' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here
  
  # Skip frameworks you're not going to use (only works if using vendor/rails)
  # config.frameworks -= [ :action_web_service, :action_mailer ]

  # Only load the plugins named here, by default all plugins in vendor/plugins are loaded
  # config.plugins = %W( exception_notification ssl_requirement )

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Use the database for sessions instead of the file system
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  config.active_record.observers = :user_observer, :news_observer

  # Make Active Record use UTC-base instead of local time
  config.active_record.default_timezone = :utc
  
  # See Rails::Configuration for more options
  config.action_mailer.delivery_method = :smtp
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf
# Mime::Type.register "application/x-mobile", :mobile

# Include your application configuration below
require 'action_mailer/ar_mailer'

# Hostname, Sitename, etc. used in mailouts and page titles
HOST = 'http://localhost:3009'
SITENAME = 'Viper'
TAGLINE = 'Your Social Community Starts Here'

# Database max limits
DB_STRING_MAX_LENGTH = 255
DB_TEXT_MAX_LENGTH = 65000

# Partial defaults
MAINCOL_ONE = "layouts/maincol_one"
MAINCOL_TWO = "layouts/maincol_two"
SIDEBAR_ONE = "layouts/sidebar_one"
SIDEBAR_TWO = "layouts/sidebar_two"

VIPER_EMAIL = "dev@digitalblueprint.co.uk"

ExceptionNotifier.exception_recipients = [ 'kevin.ansfield@gmail.com' ]
ExceptionNotifier.sender_address = 'dev@digitalblueprint.co.uk'
ExceptionNotifier.email_prefix = "[VIPER SITE ERROR] "

ActionMailer::Base.smtp_settings = {
  :address => "mail.bn23hosting.com",
  :port => 25,
  :domain => "digitalblueprint.co.uk",
  :authentication => :login,
  :user_name => "dev@digitalblueprint.co.uk",
  :password => "smegsmeg23"
}

GeoKit::default_units = :miles
GeoKit::default_formula = :sphere

GeoKit::Geocoders::timeout = 3

GeoKit::Geocoders::proxy_addr = nil
GeoKit::Geocoders::proxy_port = nil
GeoKit::Geocoders::proxy_user = nil
GeoKit::Geocoders::proxy_pass = nil

GeoKit::Geocoders::yahoo = '4.bBZfXV34HvEo8jfXTIqaHvOinRUnxvVZ2exGz2dW_ecRLcgjcwc9NCDq1k7vSP'
GeoKit::Geocoders::google = 'ABQIAAAAkkvTxkn9DnTASsN5secz2BREk-kYFT-DIeF0r853jGgjIAL4cxTgJhw0ONa2EURxYaINZ-CAvVGaUQ'
GeoKit::Geocoders::geocoder_us = false 
GeoKit::Geocoders::geocoder_ca = false
GeoKit::Geocoders::provider_order = [:google,:yahoo]