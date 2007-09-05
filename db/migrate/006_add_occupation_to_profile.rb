class AddOccupationToProfile < ActiveRecord::Migration
  def self.up
    add_column "profiles", "occupation", :string, :default => ""
  end

  def self.down
    remove_column "profiles", "occupation"
  end
end
