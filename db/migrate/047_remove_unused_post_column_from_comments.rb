class RemoveUnusedPostColumnFromComments < ActiveRecord::Migration
  def self.up
    remove_column :comments, :post_id
  end

  def self.down
    add_column :comments, :post_id, :integer
  end
end
