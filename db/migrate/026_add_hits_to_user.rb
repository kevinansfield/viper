class AddHitsToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :hits, :integer, :default => 0
  end

  def self.down
    remove_column :users, :hits
  end
end
