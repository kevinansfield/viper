class AddPermalinkToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :permalink, :string
    Article.find(:all).each(&:save)
  end

  def self.down
    remove_column :articles, :permalink
  end
end
