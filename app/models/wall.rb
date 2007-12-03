class Wall < ActiveRecord::Base
  belongs_to :user
  has_many :comments, :as => :commentable, :order => 'created_at DESC', :dependent => :destroy
end