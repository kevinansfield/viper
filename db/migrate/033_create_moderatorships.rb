class CreateModeratorships < ActiveRecord::Migration
  def self.up
    create_table :moderatorships do |t|
      t.belongs_to :forum
      t.belongs_to :user
      t.timestamps
    end
  end

  def self.down
    drop_table :moderatorships
  end
end
