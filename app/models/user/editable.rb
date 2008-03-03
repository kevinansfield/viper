module User::Editable
  def editable_by?(user)
    case self.class.to_s
      when 'Forum', 'ForumTopic', 'ForumPost'
        return user && (user.id == user_id || user.moderator_of?(forum))
      else
        return user && user.id == user_id
    end
  end
end