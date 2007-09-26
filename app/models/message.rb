class Message < ActiveRecord::Base
  belongs_to :sender,
             :foreign_key => 'sender_id',
             :class_name => 'User'
             
  belongs_to :receiver,
             :foreign_key => 'receiver_id',
             :class_name => 'User'
             
  acts_as_textiled :body
             
  validates_presence_of :subject, :body
  
  cattr_reader :per_page
  @@per_page = 10
  
  def read?
    !self.read_at.nil?
  end
  
end
