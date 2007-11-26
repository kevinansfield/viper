class Category < ActiveRecord::Base
  has_many :articles
  
  validates_presence_of :name
  validates_length_of :name, :maximum => DB_STRING_MAX_LENGTH
end
