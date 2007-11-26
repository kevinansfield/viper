class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.column :user_id, :integer
      t.column :category_id, :integer
      t.column :title, :string
      t.column :body, :text
      t.column :created_at, :datetime
      t.column :updated_at, :datetime
    end
  end

  def self.down
    drop_table :articles
  end
end