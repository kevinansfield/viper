class Article < ActiveRecord::Base
  belongs_to :category
  belongs_to :user
  
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
end
