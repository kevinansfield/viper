class CreateImContacts < ActiveRecord::Migration
  def self.up
    create_table :im_contacts do |t|
      t.column :profile_id, :integer
      t.column :contact, :string
      t.column :service, :string
    end
  end

  def self.down
    drop_table :im_contacts
  end
end
