class CommentObserver < ActiveRecord::Observer
  
  def after_create(comment)
    UserMailer.deliver_blog_comment_notification(comment)
  end
  
end
