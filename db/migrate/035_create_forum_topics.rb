class CreateForumTopics < ActiveRecord::Migration
  def self.up
    create_table :forum_topics do |t|
      t.belongs_to :user
      t.belongs_to :forum
      t.string :title
      t.integer :hits, :default => 0
      t.integer :sticky
      t.integer :posts_count, :default => 0
      t.boolean :locked, :default => false
      t.integer :last_post_id
      t.datetime :last_updated_at
      t.integer :last_user_id
      t.string :permalink
      t.timestamps
    end
    
    add_index "forum_topics", ["sticky", "last_updated_at", "forum_id"], :name => "index_forum_topics_on_sticky_and_last_updated_at"
    add_index "forum_topics", ["last_updated_at", "forum_id"], :name => "index_forum_topics_on_forum_id_and_last_updated_at"
    add_index "forum_topics", ["forum_id", "permalink"], :name => "index_forum_topics_on_forum_id_and_permalink"
  end

  def self.down
    drop_table :forum_topics
  end
end
