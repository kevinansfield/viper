class AddDescriptionToArticles < ActiveRecord::Migration
  def self.up
    add_column "articles", "description", :text
  end

  def self.down
    remove_column "articles", "description"
  end
end
