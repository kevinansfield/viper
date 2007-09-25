class CreateNews < ActiveRecord::Migration
  def self.up
    create_table :news do |t|
      t.column :user_id, :integer
      t.column :title, :string
      t.column :body, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :news
  end
end
