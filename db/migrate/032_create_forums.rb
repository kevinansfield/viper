class CreateForums < ActiveRecord::Migration
  def self.up
    create_table :forums do |t|
      t.string :name
      t.string :description
      t.integer :topics_count, :default => 0
      t.integer :posts_count, :default => 0
      t.integer :position, :default => 0
      t.text :description
      t.string :state, :default => 'public'
      t.string :permalink
    end
  end

  def self.down
    drop_table :forums
  end
end
