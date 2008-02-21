class RenameForumCounters < ActiveRecord::Migration
  def self.up
    rename_column :forums, :topics_count, :forum_topics_count
    rename_column :forums, :posts_count, :forum_posts_count
  end

  def self.down
  end
end
