class UpdateTaggingsTableForActsAsTaggableOn < ActiveRecord::Migration
  def self.up
    add_column :taggings, :context, :string
    add_column :taggings, :tagger_id, :integer
    add_column :taggings, :tagger_type, :string
    
    remove_index :taggings, [:taggable_id, :taggable_type]
    add_index :taggings, [:taggable_id, :taggable_type, :context]
  end

  def self.down
    remove_index :taggings, [:taggable_id, :taggable_type, :context]
    add_index :taggings, [:taggable_id, :taggable_type]
    
    remove_column :taggings, :context, :string
    remove_column :taggings, :tagger_id, :integer
    remove_column :taggings, :tagger_type, :string
  end
end
