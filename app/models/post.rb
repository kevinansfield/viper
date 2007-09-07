class Post < ActiveRecord::Base
  belongs_to :blog
  
  validates_presence_of :title, :body, :blog
  validates_length_of :title, :maximum => DB_STRING_MAX_LENGTH
  validates_length_of :body,  :maximum => DB_TEXT_MAX_LENGTH
  
  cattr_reader :per_page
  @@per_page = 10
end
