# == Schema Information
# Schema version: 49
#
# Table name: forum_posts
#
#  id         :integer(11)     not null, primary key
#  user_id    :integer(11)     
#  topic_id   :integer(11)     
#  forum_id   :integer(11)     
#  body       :text            
#  created_at :datetime        
#  updated_at :datetime        
#

class ForumPost < ActiveRecord::Base
  include User::Editable
  include ActivityLogger

  # author of post
  belongs_to :user, :counter_cache => true
  
  belongs_to :topic,
             :foreign_key => 'topic_id',
             :class_name => 'ForumTopic',
             :counter_cache => :posts_count
             
  # topic's forum (set by callback)
  belongs_to :forum, :counter_cache => :posts_count
  
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
  
  acts_as_textiled :body
  
  validates_presence_of :user_id, :topic_id, :forum_id, :body
  validate :topic_is_not_locked

  after_create  :update_cached_fields
  after_create  :log_activity
  after_destroy :update_cached_fields

  attr_accessible :body

  def self.search(query, options = {})
    options[:conditions] ||= ["LOWER(#{ForumPost.table_name}.body) LIKE ?", "%#{query}%"] unless query.blank?
    options[:select]     ||= "#{ForumPost.table_name}.*, #{ForumTopic.table_name}.title as topic_title, #{Forum.table_name}.name as forum_name"
    options[:joins]      ||= "inner join #{ForumTopic.table_name} on #{ForumPost.table_name}.topic_id = #{ForumTopic.table_name}.id inner join #{Forum.table_name} on #{ForumTopic.table_name}.forum_id = #{Forum.table_name}.id"
    options[:order]      ||= "#{ForumPost.table_name}.created_at DESC"
    options[:count]      ||= {:select => "#{ForumPost.table_name}.id"}
    paginate options
  end

protected
  def update_cached_fields
    topic.update_cached_post_fields(self)
  end
  
  def topic_is_not_locked
    errors.add_to_base("Topic is locked") if topic && topic.locked?
  end
  
private
  def log_activity
    add_activities(:item => self, :user => user)
  end
end
