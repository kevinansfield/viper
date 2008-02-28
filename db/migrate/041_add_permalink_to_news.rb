class AddPermalinkToNews < ActiveRecord::Migration
  def self.up
    add_column :news, :permalink, :string
    News.find(:all).each(&:save)
  end

  def self.down
    remove_column :news, :permalink
  end
end
