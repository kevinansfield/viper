class AddAutherAboutToBio < ActiveRecord::Migration
  def self.up
    add_column 'bios', 'author_about', :text
  end

  def self.down
    remove_column 'bios', 'author_about'
  end
end
