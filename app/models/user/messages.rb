class User
  # Alias for all received messages
  def received_messages
    self.messages_as_receiver
  end
  
  # Alias for all sent messages
  def sent_messages
    self.messages_as_sender
  end
  
  # Alias for unread messages
  def new_messages
    self.unread_messages
  end

  # Alias for read messages
  def old_messages
    self.read_messages
  end

  # Accepts a message object and flags the message as deleted by sender
  def delete_from_sent(message)
    if message.sender_id == self.id
      message.update_attribute :sender_deleted, true
      return true
    else
      return false
    end
  end

  # Accepts a message object and flags the message as deleted by the sender
  def delete_from_received(message)
    if message.receiver_id == self.id
      message.update_attribute :receiver_deleted, true
      return true
    else
      return false
    end
  end

  # Accepts a user object as the receiver, and a message
  # and creates a message relationship joining the two users
  def send_message(receiver, message)
    Message.create!(:sender => self, :receiver => receiver, :subject => message.subject, :body => message.body)
  end
end