# == Schema Information
# Schema version: 47
#
# Table name: walls
#
#  id      :integer(11)     not null, primary key
#  user_id :integer(11)     
#

class Wall < ActiveRecord::Base
  belongs_to :user
  has_many :comments, :as => :commentable, :order => 'created_at DESC', :dependent => :destroy
end
