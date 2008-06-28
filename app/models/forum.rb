# == Schema Information
# Schema version: 49
#
# Table name: forums
#
#  id           :integer(11)     not null, primary key
#  name         :string(255)     
#  description  :string(255)     
#  topics_count :integer(11)     
#  posts_count  :integer(11)     
#  position     :integer(11)     default(0)
#  state        :string(255)     default("public")
#  permalink    :string(255)     
#

class Forum < ActiveRecord::Base
  acts_as_list
  
  validates_presence_of :name
  has_permalink :name
  
  attr_readonly :posts_count, :topics_count
  
  acts_as_textiled :description
  
  has_many :topics, :class_name => 'ForumTopic', :order => "#{ForumTopic.table_name}.sticky desc, #{ForumTopic.table_name}.last_updated_at desc", :dependent => :delete_all

  # this is used to see if a forum is "fresh"... we can't use topics because it puts
  # stickies first even if they are not the most recently modified
  has_many :recent_topics, :class_name => 'ForumTopic', :order => "#{ForumTopic.table_name}.last_updated_at DESC"
  has_one  :recent_topic,  :class_name => 'ForumTopic', :order => "#{ForumTopic.table_name}.last_updated_at DESC"

  has_many :posts,       :class_name => 'ForumPost', :order => "#{ForumPost.table_name}.created_at DESC", :dependent => :delete_all
  has_one  :recent_post, :class_name => 'ForumPost', :order => "#{ForumPost.table_name}.created_at DESC"

  has_many :moderatorships, :dependent => :delete_all
  has_many :moderators, :through => :moderatorships, :source => :user
  
  def self.ordered
    find :all, :order => 'position'
  end
  
  def to_param
    permalink
  end
end
