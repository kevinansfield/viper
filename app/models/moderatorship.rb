# == Schema Information
# Schema version: 45
#
# Table name: moderatorships
#
#  id         :integer(11)     not null, primary key
#  forum_id   :integer(11)     
#  user_id    :integer(11)     
#  created_at :datetime        
#  updated_at :datetime        
#

class Moderatorship < ActiveRecord::Base
  belongs_to :user
  belongs_to :forum
  validates_presence_of :user_id, :forum_id
  validate :uniqueness_of_relationship
  
protected
  def uniqueness_of_relationship
    if self.class.exists?(:user_id => user_id, :forum_id => forum_id)
      errors.add_to_base("Cannot add duplicate user/forum relation")
    end
  end
end
