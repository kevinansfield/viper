class AddIsAttachmentColumnsToAvatars < ActiveRecord::Migration
  def self.up
    add_column :avatars, :crop_options, :string
    add_column :avatars, :version_name, :string
    add_column :avatars, :base_version_id, :integer
    add_column :avatars, :file_size, :integer
    add_column :avatars, :aspect_ratio, :float
    
    avatars = Avatar.find(:all)
    for avatar in avatars
      avatar.destroy unless avatar.parent_id.nil?
    end
    
    remove_column :avatars, :parent_id
    remove_column :avatars, :thumbnail
    remove_column :avatars, :size
  end

  def self.down
    remove_column :avatars, :crop_options
    remove_column :avatars, :version_name
    remove_column :avatars, :base_version_id
    remove_column :avatars, :file_size
    remove_column :avatars, :aspect_ratio
  end
end
