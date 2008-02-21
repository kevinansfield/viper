class CreateForumPosts < ActiveRecord::Migration
  def self.up
    create_table :forum_posts do |t|
      t.belongs_to :user
      t.belongs_to :forum_topic
      t.belongs_to :forum
      t.text :body
      t.timestamps
    end
  
    add_index "forum_posts", ["created_at", "forum_id"], :name => "index_forum_posts_on_forum_id"
    add_index "forum_posts", ["created_at", "user_id"], :name => "index_forum_posts_on_user_id"
    add_index "forum_posts", ["created_at", "forum_topic_id"], :name => "index_forum_posts_on_forum_topic_id"
  end

  def self.down
    drop_table :forum_posts
  end
end
