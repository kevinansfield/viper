class News < ActiveRecord::Base
  belongs_to :user
  
  acts_as_textiled :body
  
  has_permalink :title
  
  validates_presence_of :title, :body, :user
  validates_length_of :title, :maximum => 255
  validates_length_of :body,  :maximum => 65000
  # Prevent duplicate posts.
  validates_uniqueness_of :body, :scope => [:title]
  
  cattr_reader :per_page
  @@per_page = 10
  
  def send_as_email
    @send_as_email = true
  end
  
  def send_as_email?
    @send_as_email
  end
  
  # Return true for a duplicate post (same title and body).
  def duplicate?
    news = News.find_by_title_and_body(title, body)
    # Give self the id for REST routing purposes.
    self.id = news.id unless news.nil?
    not news.nil?
  end
  
  def self.find_latest(number = 5)
    find :all, :limit => number, :order => 'created_at DESC'
  end
  
  def to_param
    permalink
  end
end
