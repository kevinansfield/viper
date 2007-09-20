class Avatar < ActiveRecord::Base
  belongs_to :user
  
  has_attachment  :content_type => :image,
                  :storage => :file_system,
                  :size => 0..500.kilobytes,
                  :resize_to => '300x900',
                  :thumbnails => { :thumb => '100x300',
                                   :small => '150x450' },
                  :processor => 'rmagick'
  
  validates_presence_of :size, :content_type, :filename
  validate              :attachment_attributes_valid?
  
  protected
  
    # validates the size and content_type attributes according to the current model's options
    def attachment_attributes_valid?
      [:content_type].each do |attr_name|
        enum = attachment_options[attr_name]
        errors.add attr_name, 'is not a valid image type' unless enum.nil? || enum.include?(send(attr_name))
      end
      [:size].each do |attr_name|
        enum = attachment_options[attr_name]
        errors.add attr_name, 'is too large, images should be no larger than 500KB' unless enum.nil? || enum.include?(send(attr_name))
      end
    end
end
