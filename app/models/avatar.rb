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
  
  validates_presence_of :size, :content_type, :filename
  
  # validates the size and content_type attributes according to the current model's options
  def validate
    [:content_type].each do |attr_name|
      enum = attachment_options[attr_name]
      errors.add attr_name, 'is not a valid image type' unless enum.nil? || enum.include?(send(attr_name))
    end
    [:size].each do |attr_name|
      enum = attachment_options[attr_name]
      errors.add attr_name, 'is not in our acceptable range, image size should be 5KB to 500KB' unless enum.nil? || enum.include?(send(attr_name))
    end
  end
end
