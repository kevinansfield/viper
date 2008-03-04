class Avatar < ActiveRecord::Base
  belongs_to :user
  
#  has_attachment  :content_type => :image,
#                  :storage => :file_system,
#                  :min_size => 5.kilobytes,
#                  :max_size => 500.kilobytes,
#                  :thumbnails => { :large => '300x450',
#                                   :small => '150x225',
#                                   :thumb => '100x150',
#                                   :tiny  => '60x90',
#                                   :micro => '25x25'},
#                  :processor => 'rmagick'
#
#  validates_attachment :content_type => "The file you uploaded was not a JPEG, PNG or GIF",
#                       :size         => "The image you uploaded was larger than the maximum size of 500KB" 
  
  is_attachment   :validate => {       :content_type => :image,
                                       :max_file_size => 2.megabytes },
                  :image_versions => { :large => '300x',
                                       :small => '150x',
                                       :small_square => { :cropper => 150 },
                                       :thumb => '100x',
                                       :thumb_square => { :cropper => 100 },
                                       :tiny  => { :cropper => 60 },
                                       :micro => { :cropper => 25 }}
                                       
  CROP_VERSIONS = %w(small_square thumb_square tiny micro)
  
  def self.calculate_crop_options(crop_calcs, ratio)
    unless crop_calcs.nil?
      crop_calcs["x1"] = (crop_calcs["x1"].to_f * ratio).to_i
      crop_calcs["y1"] = (crop_calcs["y1"].to_f * ratio).to_i
      crop_calcs["x2"] = (crop_calcs["x2"].to_f * ratio).to_i
      crop_calcs["y2"] = (crop_calcs["y2"].to_f * ratio).to_i
      crop_calcs["width"] = (crop_calcs["width"].to_f * ratio).to_i
      crop_calcs["height"] = (crop_calcs["height"].to_f * ratio).to_i
      crop_calcs
    end
  end
  
  def self.crop_all_versions!(avatar, cropper_options, scale_version = 'large')
    base = avatar.is_base_version? ? avatar : avatar.base_version
    scale = base.versions.find_by_version_name(scale_version)
    
    ratio = base.width.to_f / scale.width.to_f
    crop_calcs = Avatar.calculate_crop_options(cropper_options, ratio)
    
    CROP_VERSIONS.each do |version|
      cropped_avatar = base.versions.find_by_version_name(version)
      cropped_avatar.update_attribute(:crop_options, crop_calcs)
    end
    
    avatar.reprocess_base_version
  end
  
  def self.default
    self.find(:first, :conditions => ["filename = 'viper_default.png' AND base_version_id IS NULL"])
  end
  
#  def self.max_crop_all_versions!(avatar)
#    base = avatar.base_version || avatar
#    max = base.width < base.height ? base.width : base.height
#    
#    crop_calcs = Hash.new
#    crop_calcs["x1"] = 0
#    crop_calcs["y1"] = 0
#    crop_calcs["x2"] = max
#    crop_calcs["y2"] = max
#    crop_calcs["width"] = max
#    crop_calcs["height"] = max
#    
#    CROP_VERSIONS.each do |version|
#      cropped_avatar = base.versions.find_by_version_name(version)
#      cropped_avatar.update_attribute(:crop_options, crop_calcs)
#    end
#    
#    avatar.reprocess_base_version
#  end
end
