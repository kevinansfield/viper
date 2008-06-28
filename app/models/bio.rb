# == Schema Information
# Schema version: 49
#
# Table name: bios
#
#  id           :integer(11)     not null, primary key
#  user_id      :integer(11)     
#  about        :text            
#  interests    :text            
#  music        :text            
#  films        :text            
#  television   :text            
#  books        :text            
#  heroes       :text            
#  author_about :text            
#

class Bio < ActiveRecord::Base
  include ActivityLogger
  
  belongs_to :user
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
  
  after_initialize :clear_text_fields
  after_save :log_activity
  
  QUESTIONS = %w(about interests music films television books heroes)
  # A constant for everything except the bio
  FAVORITES = QUESTIONS - %w(about author_about)
  
  acts_as_ferret :remote => false
  acts_as_textiled :about
  
  validates_length_of QUESTIONS, :maximum => 65000
  validates_length_of :author_about, :maximum => 1000
  
  def interests
    TagList.new(self[:interests], :parse => true)
  end
  
  def music
    TagList.new(self[:music], :parse => true)
  end
  
  def films
    TagList.new(self[:films], :parse => true)
  end
  
  def television
    TagList.new(self[:television], :parse => true)
  end
  
  def books
    TagList.new(self[:books], :parse => true)
  end
  
  def heroes
    TagList.new(self[:heroes], :parse => true)
  end
                       
private
  
  def clear_text_fields
    QUESTIONS.each do |question|
      self[question] ||=  ""
    end
  end
  
  def log_activity
    add_activities(:item => self, :user => user)
  end
  
end
