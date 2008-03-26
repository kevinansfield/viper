# == Schema Information
# Schema version: 45
#
# Table name: blogs
#
#  id        :integer(11)     not null, primary key
#  user_id   :integer(11)     
#  permalink :string(255)     
#

class Blog < ActiveRecord::Base
  include User::Editable
  
  belongs_to :user
  
  has_permalink :username
  
  has_many :posts, :order => "created_at DESC"
  
  def find_posts_prior_to_last(number = 5)
    posts = self.posts.find :all, :limit => number + 1
    posts.shift
    return posts
  end
  
  def to_param
    permalink
  end
  
private

  def username
    user.login
  end
  
end
