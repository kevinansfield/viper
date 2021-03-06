# == Schema Information
# Schema version: 49
#
# Table name: articles
#
#  id          :integer(11)     not null, primary key
#  user_id     :integer(11)     
#  category_id :integer(11)     
#  title       :string(255)     
#  body        :text            
#  created_at  :datetime        
#  updated_at  :datetime        
#  description :text            
#  permalink   :string(255)     
#

class Article < ActiveRecord::Base
  include ActivityLogger
  
  belongs_to :category
  belongs_to :user
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
  
  after_create :log_activity
  
  has_permalink :title
  
  validates_presence_of :title, :description, :body
  validates_length_of :title, :maximum => DB_STRING_MAX_LENGTH
  validates_length_of :body,  :maximum => DB_TEXT_MAX_LENGTH
  validates_length_of :description, :maximum => DB_TEXT_MAX_LENGTH
  # Prevent duplicate articles.
  validates_uniqueness_of :body, :scope => [:title, :category_id]
  
  cattr_reader :per_page
  @@per_page = 10
  
  acts_as_textiled :body
  
  # Return true for a duplicate post (same title and body).
  def duplicate?
    article = Article.find_by_category_id_and_title_and_body(category_id, title, body)
    # Give self the id for REST routing purposes.
    self.id = article.id unless article.nil?
    not article.nil?
  end
  
  def self.find_latest(number = 5)
    find :all, :limit => number, :order => 'created_at DESC'
  end
  
  def self.find_archive(offset = 5, number = nil)
    articles = find :all, :limit => number, :order => 'created_at DESC'
    articles = articles[0, articles.length - offset]
  end
  
  def self.find_latest_by_unique_categories(number = 5)
    self.find_by_sql ["SELECT articles. * FROM articles INNER JOIN (SELECT MAX(id) AS id FROM articles GROUP BY category_id) ids ON articles.id = ids.id ORDER BY created_at DESC LIMIT ?", number]
  end
  
  def self.find_latest_by_unique_authors(number = 5)
    # Could return incorrect data if posts ever get created with lower ids than the highest id in the table - is this even possible in mysql?
    # Possible to use MAX(created_at) in the inner join instead, but not sure what happens if two posts end up with the same created_at
    # TODO: Test/investigate above scenarios
    self.find_by_sql ["SELECT articles. * FROM articles INNER JOIN (SELECT MAX(id) AS id FROM articles GROUP BY user_id) ids ON articles.id = ids.id ORDER BY created_at DESC LIMIT ?", number]
  end
  
  def to_param
    permalink
  end
  
private

  def log_activity
    add_activities(:item => self, :user => user)
  end
end
