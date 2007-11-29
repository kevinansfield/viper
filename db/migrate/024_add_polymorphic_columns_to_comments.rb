class AddPolymorphicColumnsToComments < ActiveRecord::Migration
  def self.up
    add_column :comments, :commentable_id, :integer
    add_column :comments, :commentable_type, :string
    
    Comment.find(:all).each do |comment|
      comment.commentable_type = 'Post'
      comment.commentable_id = comment.post_id
      comment.save
    end
  end

  def self.down
    remove_column :comments, :commentable_id
    remove_column :comments, :commentable_type
  end
end
