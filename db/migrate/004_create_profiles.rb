class CreateProfiles < ActiveRecord::Migration
  def self.up
    create_table :profiles do |t|
      t.column :user_id,      :integer, :null => false, :default => 0
      t.column :first_name,   :string, :default => ""
      t.column :last_name,    :string, :default => ""
      t.column :gender,       :string
      t.column :birthdate,    :date
      t.column :city,         :string, :default => ""
      t.column :county,       :string, :default => ""
      t.column :post_code,    :string, :default => ""
      t.column :lat,          :float
      t.column :lng,          :float
    end
  end

  def self.down
    drop_table :profiles
  end
end
