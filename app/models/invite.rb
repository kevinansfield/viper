# == Schema Information
# Schema version: 49
#
# Table name: tablelesses
#
#  user_id    :integer         
#  recipients :text            
#  message    :text            
#

class Invite < Tableless
  column :user_id,        :integer
  column :recipients,     :text
  column :message,        :text
  
  belongs_to :user
  
  validates_presence_of :recipients
                        
  def recipient_addresses
    addresses = recipients.split(',').map{|p| p.strip}
  end
                        
  def validate
    recipient_addresses.each do |address|
      errors.add_to_base "#{address} is not a valid email address" unless address =~ /^[A-Z0-9._%-]+@([A-Z0-9-]+\.)+[A-Z]{2,4}$/i
      if User.find_by_email(address)
        errors.add_to_base "#{address} is already a member!"
      end
    end
  end
  
  def send_invites
    recipient_addresses.each do |address|
      invite = {:recipient => address,
                :sender_name => user.full_name,
                :message => message,
                :user => user}
      UserMailer.deliver_invite(invite)
    end
  end
end
