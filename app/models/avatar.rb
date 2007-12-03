class Avatar < ActiveRecord::Base
  belongs_to :user
  
  has_attachment  :content_type => :image,
                  :storage => :file_system,
                  :min_size => 5.kilobytes,
                  :max_size => 500.kilobytes,
                  :thumbnails => { :large => '300x450',
                                   :small => '150x225',
                                   :thumb => '100x150',
                                   :tiny  => '60x90',
                                   :micro => '25x25'},
                  :processor => 'rmagick'
  
  validates_attachment :content_type => "The file you uploaded was not a JPEG, PNG or GIF",
                       :size         => "The image you uploaded was larger than the maximum size of 500KB" 
  
end
