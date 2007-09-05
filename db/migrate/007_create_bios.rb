class CreateBios < ActiveRecord::Migration
  def self.up
    create_table :bios do |t|
      t.column "user_id",     :integer
      t.column "about",       :text
      t.column "interests",   :text
      t.column "music",       :text
      t.column "films",       :text
      t.column "television",  :text
      t.column "books",       :text
      t.column "heroes",      :text
    end
  end

  def self.down
    drop_table :bios
  end
end
