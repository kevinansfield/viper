# == Schema Information
# Schema version: 49
#
# Table name: friendships
#
#  id          :integer(11)     not null, primary key
#  user_id     :integer(11)     
#  friend_id   :integer(11)     
#  status      :string(255)     
#  created_at  :datetime        
#  accepted_at :datetime        
#

class Friendship < ActiveRecord::Base
  belongs_to :user
  belongs_to :friend, :class_name => "User", :foreign_key => "friend_id"
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
  
  validates_presence_of :user_id, :friend_id
  
  # Status codes.
  ACCEPTED  = 'accepted'
  REQUESTED = 'requested'
  PENDING   = 'pending'
  
  # Accept a connection request (instance method).
  # Each connection is really two rows, so delegate this method
  # to Connection.accept to wrap the whole thing in a transaction.
  def accept
    Friendship.accept(user_id, friend_id)
  end
  
  def breakup
    Friendship.breakup(user_id, friend_id)
  end
  
  class << self
  
    # Return true if the users are (possibly pending) friends.
    def exists?(user, friend)
      not find_by_user_id_and_friend_id(user, friend).nil?
    end
    
    alias exist? exists?
    
    # Record a pending friend request
    def request(user, friend)
      unless user == friend or Friendship.exists?(user, friend)
        transaction do
          create(:user => user, :friend => friend, :status => PENDING)
          create(:user => friend, :friend => user, :status => REQUESTED)
        end
      end
    end
    
    # Accept a friend request.
    def accept(user, friend)
      transaction do
        accepted_at = Time.now
        accept_one_side(user, friend, accepted_at)
        accept_one_side(friend, user, accepted_at)
        
        # Log friendship activity
        Activity.create!(:item => friendship(user, friend))
      end
    end
    
    # Delete a friendship or cancel a pending request
    def breakup(user, friend)
      transaction do
        destroy(friendship(user, friend))
        destroy(friendship(friend, user))
      end
    end
    
    # Return a friendship based on the user and friend.
    def friendship(user, friend)
      find_by_user_id_and_friend_id(user, friend)
    end
    
    def accepted?(user, friend)
      friendship(user, friend).status == ACCEPTED
    end
    
    def friends?(user, friend)
      exist?(user, friend) and accepted?(user, friend)
    end
  
  end
  
  private
  
  # Update the db with one side of an accepted friendship request.
  def self.accept_one_side(user, friend, accepted_at)
    friendship(user, friend).update_attributes!( :status => ACCEPTED,
                                                 :accepted_at => accepted_at )
  end
end
