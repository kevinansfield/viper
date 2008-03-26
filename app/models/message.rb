# == Schema Information
# Schema version: 45
#
# Table name: messages
#
#  id               :integer(11)     not null, primary key
#  sender_id        :integer(11)     not null
#  receiver_id      :integer(11)     not null
#  subject          :string(255)     default(""), not null
#  body             :text            
#  created_at       :datetime        
#  read_at          :datetime        
#  sender_deleted   :boolean(1)      
#  receiver_deleted :boolean(1)      
#  sender_purged    :boolean(1)      
#  receiver_purged  :boolean(1)      
#

class Message < ActiveRecord::Base
  belongs_to :sender,
             :foreign_key => 'sender_id',
             :class_name => 'User'
             
  belongs_to :receiver,
             :foreign_key => 'receiver_id',
             :class_name => 'User'
  
  validates_presence_of :subject, :body
  
  cattr_reader :per_page
  @@per_page = 10
  
  def read!
    self.read_at = Time.now
    self.save
  end
  
  def read?
    !self.read_at.nil?
  end
  
  def delete(user)
    if user == self.receiver
      self.receiver_deleted = true
    elsif user == self.sender
      self.sender_deleted = true
    end
    self.save
    self.destroy if purge?
  end
  
  private
  
  def purge?
    receiver_deleted and sender_deleted
  end
  
end
