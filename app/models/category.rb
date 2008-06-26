# == Schema Information
# Schema version: 47
#
# Table name: categories
#
#  id          :integer(11)     not null, primary key
#  name        :string(255)     
#  description :text            
#  permalink   :string(255)     
#

class Category < ActiveRecord::Base
  has_many :articles, :dependent => :destroy
  
  has_permalink :name
  
  validates_presence_of :name
  validates_length_of :name, :maximum => DB_STRING_MAX_LENGTH
  
  def to_param
    permalink
  end
end
