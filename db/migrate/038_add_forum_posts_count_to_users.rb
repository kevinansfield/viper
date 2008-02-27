class AddForumPostsCountToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :forum_posts_count, :integer, :default => 0
  end

  def self.down
    remove_column :users, :forum_posts_count
  end
end
