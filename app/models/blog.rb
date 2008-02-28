class Blog < ActiveRecord::Base
  belongs_to :user
  
  has_permalink :username
  
  has_many :posts, :order => "created_at DESC"
  
  def find_posts_prior_to_last(number = 5)
    posts = self.posts.find :all, :limit => number + 1
    posts.shift
    return posts
  end
  
private

  def username
    user.login
  end
  
  def to_param
    permalink
  end
end
