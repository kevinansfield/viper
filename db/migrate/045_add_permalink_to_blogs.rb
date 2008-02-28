class AddPermalinkToBlogs < ActiveRecord::Migration
  def self.up
    add_column :blogs, :permalink, :string
    Blog.find(:all).each(&:save)
  end

  def self.down
    remove_column :blogs, :permalink
  end
end
