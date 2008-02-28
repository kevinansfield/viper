class AddPermalinkToCategories < ActiveRecord::Migration
  def self.up
    add_column :categories, :permalink, :string
    Category.find(:all).each(&:save)
  end

  def self.down
    remove_column :categories, :permalink
  end
end
