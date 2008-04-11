# == Schema Information
# Schema version: 47
#
# Table name: im_contacts
#
#  id         :integer(11)     not null, primary key
#  profile_id :integer(11)     
#  contact    :string(255)     
#  service    :string(255)     
#

class ImContact < ActiveRecord::Base
  belongs_to :profile
  
  SERVICES = %w(AIM Yahoo MSN GTalk/Jabber Skype)
  
  #validates_presence_of :name
  #validates_presence_of :service
  #validates_inclusion_of :service, :in => SERVICES
end
