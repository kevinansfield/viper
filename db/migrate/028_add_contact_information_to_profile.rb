class AddContactInformationToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :website, :string
  end

  def self.down
    remove_column :profiles, :website
  end
end
