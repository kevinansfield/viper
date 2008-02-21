class AuthenticationException < StandardError; end
  
class User < ActiveRecord::Base
  concerned_with :validation, :activation, :authentication, :messages, :forum_posting
  
  acts_as_ferret :fields => ['login', 'email'], :remote => false
  
  has_one  :profile
  has_one  :avatar
  has_one  :bio
  has_one  :blog
  has_one  :wall
  
  has_many :comments
  has_many :news
  has_many :articles
  
  has_many :friendships
  has_many :friends,            :through => :friendships, :conditions => "status = 'accepted'"
  has_many :requested_friends,  :through => :friendships, :source => :friend, :conditions => "status = 'requested'"
  has_many :pending_friends,    :through => :friendships, :source => :friend, :conditions => "status = 'pending'"
           
  has_many :messages_as_sender,   :foreign_key => 'sender_id',    :class_name => 'Message', :conditions => 'sender_deleted IS NULL', :order => 'created_at DESC'
  has_many :messages_as_receiver, :foreign_key => 'receiver_id',  :class_name => 'Message', :conditions => 'receiver_deleted IS NULL', :order => 'created_at DESC'
  has_many :unread_messages,      :foreign_key => 'receiver_id',  :class_name => 'Message', :conditions => 'read_at IS NULL AND receiver_deleted IS NULL', :order => 'created_at DESC'
  has_many :read_messages,        :foreign_key => 'receiver_id',  :class_name => 'Message', :conditions => 'read_at IS NOT NULL and receiver_deleted IS NULL', :order => 'created_at DESC'
  
  has_many :posts, :order => "#{ForumPost.table_name}.created_at desc", :class_name => 'ForumPost'
  has_many :topics, :order => "#{ForumTopic.table_name}.created_at desc", :class_name => 'ForumTopic'
  
  has_many :moderatorships, :dependent => :delete_all
  has_many :forums, :through => :moderatorships, :source => :forum
           
  has_permalink :login
  
  attr_readonly :posts_count, :last_seen_at
  
  def available_forums
    @available_forums ||= site.ordered_forums - forums
  end

  def moderator_of?(forum)
    admin? || Moderatorship.exists?(:user_id => id, :forum_id => forum.id)
  end
  
  def hit!
      self.hits += 1
      self.save!
  end
  
  def views() hits end
  
  def setup_for_display!
    self.profile ||= Profile.new
    self.avatar ||= nil
    self.bio ||= Bio.new
    self.blog ||= Blog.new
    self.wall ||= Wall.new
  end
  
  def full_name
    self.profile ||= Profile.new
    self.profile.full_name || self.login
  end
  
  def first_name
    self.profile ||= Profile.new
    self.profile.first_name.blank? ? self.login : self.profile.first_name
  end
  
  def last_name
    self.profile ||= Profile.new
    self.profile.last_name.blank? ? self.login : self.profile.last_name
  end
  
  def self.find_latest(number = 5)
    find :all, :conditions => ['activation_code IS NULL'], :limit => number, :order => 'created_at DESC'
  end
  
  def self.find_all_for_news_delivery
    find :all
  end
  
  # this is used to keep track of the last time a user has been seen (reading a topic)
  # it is used to know when topics are new or old and which should have the green
  # activity light next to them
  #
  # we cheat by not calling it all the time, but rather only when a user views a topic
  # which means it isn't truly "last seen at" but it does serve it's intended purpose
  #
  # This is now also used to show which users are online... not at accurate as the
  # session based approach, but less code and less overhead.
  def seen!
    now = Time.now.utc
    self.class.update_all ['last_seen_at = ?', now], ['id = ?', id]
    write_attribute :last_seen_at, now
  end
  
  def to_param
    permalink
  end
end
