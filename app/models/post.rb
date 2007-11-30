class Post < ActiveRecord::Base
  belongs_to :blog
  has_many :comments, :as => :commentable, :order => 'created_at', :dependent => :destroy
  
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
  
  def self.find_latest(number = 5)
    find :all, :limit => number, :order => 'created_at DESC'
  end
  
  def self.find_latest_by_unique_authors(number = 5)
    # Could return incorrect data if posts ever get created with lower ids than the highest id in the table - is this even possible in mysql?
    # Possible to use MAX(created_at) in the inner join instead, but not sure what happens if two posts end up with the same created_at
    # TODO: Test/investigate above scenarios
    self.find_by_sql ["SELECT posts. * FROM posts INNER JOIN (SELECT MAX(id) AS id FROM posts GROUP BY blog_id) ids ON posts.id = ids.id ORDER BY created_at DESC LIMIT ?", number]
  end
  
  def user
    self.blog.user
  end
end
