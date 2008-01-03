class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, :polymorphic => true
  
  validates_presence_of :body
  validates_length_of :body, :maximum => DB_TEXT_MAX_LENGTH
  
  before_create :check_for_spam
  
  acts_as_textiled :body
  
  def self.approved
    find(:all, :conditions => 'approved=1', :order => 'created_at DESC')
  end
  
  def self.recent(limit, conditions = nil)
    find(:all, :limit => limit, :conditions => conditions, :order => 'created_at DESC')
  end
  
  def request=(request)
    self.user_ip    = request.remote_ip
    self.user_agent = request.env['HTTP_USER_AGENT']
    self.referrer   = request.env['HTTP_REFERRER']
  end
  
  def check_for_spam
    self.approved = !Akismetor.spam?(akismet_attributes)
    true # return true so that it doesn't stop save
  end
  
  def akismet_attributes
    {
      :key                  => AKISMET_KEY,
      :blog                 => HOST,
      :user_ip              => user_ip,
      :user_agent           => user_agent,
      :comment_author       => user.full_name,
      :comment_author_email => user.email,
      :comment_author_url   => user.profile.website,
      :comment_content      => body
    }
  end
  
  def mark_as_ham!
    update_attribute(:approved, true)
    Akismetor.submit_ham(akismet_attributes)
  end
  
  def mark_as_spam!
    update_attribute(:approved, false)
    Akismetor.submit_spam(akismet_attributes)
  end
  
  # Prevent duplicate comments.
  # validates_uniqueness_of :body, :scope => [:user_id] # TODO: Needs reworking for polymorphic comments

  # Return true for a duplicate comment (same user and body).
  def duplicate?
    c = Comment.find_by_post_id_and_user_id_and_body(post, user, body)
    # Give self the id for REST routing purposes.
    self.id = c.id unless c.nil?
    not c.nil?
  end

  # Check authorization for destroying comments.
  def authorized?(user, parent)
    parent.user == user
  end
end
