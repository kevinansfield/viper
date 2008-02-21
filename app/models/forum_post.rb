class ForumPost < ActiveRecord::Base
  include User::Editable

  # author of post
  belongs_to :user, :counter_cache => true
  
  belongs_to :topic, :counter_cache => true, :class_name => 'ForumTopic'
  
  # topic's forum (set by callback)
  belongs_to :forum, :counter_cache => true
  
  validates_presence_of :user_id, :topic_id, :forum_id, :body
  validate :topic_is_not_locked

  after_create  :update_cached_fields
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
end