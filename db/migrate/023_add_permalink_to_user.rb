class AddPermalinkToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :permalink, :string
    User.find(:all).each(&:save)
  end

  def self.down
  end
end
