class MessageObserver < ActiveRecord::Observer
  observe Message
  
  def after_create(message)
    UserMailer.deliver_message_notification(message)
  end
  
end
