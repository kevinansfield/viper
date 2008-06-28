class UpdateUsersForNewRestfulAuthentication < ActiveRecord::Migration
  def self.up
    add_column :users, :state,        :string, :null => :no, :default => 'passive'
    add_column :users, :deleted_at,   :datetime
    add_index :users, :login, :unique => true
  end

  def self.down
    remove_column :users, :state
    remove_column :users, :deleted_at
    remove_index :users, :login
  end
end
