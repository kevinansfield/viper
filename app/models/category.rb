class Category < ActiveRecord::Base
  has_many :articles, :dependent => :nullify
  
  has_permalink :name
  
  validates_presence_of :name
  validates_length_of :name, :maximum => DB_STRING_MAX_LENGTH
  
  def to_param
    permalink
  end
end
