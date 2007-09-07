class Blog < ActiveRecord::Base
  belongs_to :user
  has_many :posts, :order => "created_at DESC"
end
