class ImContact < ActiveRecord::Base
  belongs_to :profile
  
  SERVICES = %w(AIM Yahoo MSN GTalk/Jabber Skype)
  
  #validates_presence_of :name
  #validates_presence_of :service
  #validates_inclusion_of :service, :in => SERVICES
end