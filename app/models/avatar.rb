# == Schema Information
# Schema version: 47
#
# Table name: avatars
#
#  id              :integer(11)     not null, primary key
#  user_id         :integer(11)     
#  parent_id       :integer(11)     
#  content_type    :string(255)     
#  filename        :string(255)     
#  thumbnail       :string(255)     
#  size            :integer(11)     
#  width           :integer(11)     
#  height          :integer(11)     
#  crop_options    :string(255)     
#  version_name    :string(255)     
#  base_version_id :integer(11)     
#  file_size       :integer(11)     
#  aspect_ratio    :float           
#

class Avatar < ActiveRecord::Base
  include ActivityLogger
  
  belongs_to :user
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
  
  after_save :log_activity
  
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

private

  def log_activity
    add_activities(:item => self, :user => user) unless user.nil?
  end
  
end
