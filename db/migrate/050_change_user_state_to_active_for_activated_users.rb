class ChangeUserStateToActiveForActivatedUsers < ActiveRecord::Migration
  def self.up
    users = User.find :all
    users.each { |user|
      user.activate! if user.activation_code.nil? and !user.activated_at.nil? 
    }
  end

  def self.down
  end
end
