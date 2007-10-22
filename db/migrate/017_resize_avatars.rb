class ResizeAvatars < ActiveRecord::Migration

  def self.up
    users = User.find(:all)
    users.each do |user|
      unless user.avatar.nil?
        user.avatar.thumbnails.each do |thumb|
          thumb.destroy
        end
        user.avatar.reload
        user.avatar.save
      end
    end
  end

  def self.down
  end

end
