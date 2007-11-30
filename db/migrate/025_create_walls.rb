class CreateWalls < ActiveRecord::Migration
  def self.up
    create_table :walls do |t|
      t.column :user_id, :integer
    end
    
    User.find(:all).each do |user|
      user.wall = Wall.new
      user.save
    end
  end

  def self.down
    drop_table :walls
  end
end
