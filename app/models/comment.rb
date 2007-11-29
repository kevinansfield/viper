class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  
  acts_as_textiled :body
  
  validates_presence_of :body
  validates_length_of :body, :maximum => DB_TEXT_MAX_LENGTH
  # Prevent duplicate comments.
  validates_uniqueness_of :body, :scope => [:user_id]

  # Return true for a duplicate comment (same user and body).
  def duplicate?
    c = Comment.find_by_post_id_and_user_id_and_body(post, user, body)
    # Give self the id for REST routing purposes.
    self.id = c.id unless c.nil?
    not c.nil?
  end

  # Check authorization for destroying comments.
  def authorized?(user)
    post.blog.user == user
  end
end
