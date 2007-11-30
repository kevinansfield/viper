class CommentObserver < ActiveRecord::Observer
  
  def after_create(comment)
    if comment.commentable_type == 'Post'
      UserMailer.deliver_blog_comment_notification(comment)
    elsif comment.commentable_type == 'Wall'
      # TODO: deliver wall comment notification
    end
  end
  
end
