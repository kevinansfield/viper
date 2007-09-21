class Post < ActiveRecord::Base
  belongs_to :blog
  has_many :comments, :order => 'created_at', :dependent => :destroy
  
  validates_presence_of :title, :body, :blog
  validates_length_of :title, :maximum => DB_STRING_MAX_LENGTH
  validates_length_of :body,  :maximum => DB_TEXT_MAX_LENGTH
  # Prevent duplicate posts.
  validates_uniqueness_of :body, :scope => [:title, :blog_id]
  
  cattr_reader :per_page
  @@per_page = 10
  
  acts_as_textiled :body

  # Return true for a duplicate post (same title and body).
  def duplicate?
    post = Post.find_by_blog_id_and_title_and_body(blog_id, title, body)
    # Give self the id for REST routing purposes.
    self.id = post.id unless post.nil?
    not post.nil?
  end
end
