ActionMailer::Base.default_charset = "utf-8"

# Mail server details
ActionMailer::Base.smtp_settings = {
  :address => "mta01.digitalblueprint.co.uk",
  :port => 25,
  :domain => "digitalblueprint.co.uk",
  :authentication => :login,
  :user_name => "dev@digitalblueprint.co.uk",
  :password => "smegsmeg23"
}