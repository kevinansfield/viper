class Avatar < ActiveRecord::Base
  belongs_to :user
  
  has_attachment  :content_type => :image,
                  :storage => :file_system,
                  :size => 0..500.kilobytes,
                  :resize_to => '300x900',
                  :thumbnails => { :thumb => '100x300',
                                   :small => '150x450' },
                  :processor => 'rmagick'
  
  validates_as_attachment
  
end
