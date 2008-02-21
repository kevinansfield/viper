class Attachment < ActiveRecord::Base
  is_attachment :image_engine => :rmagick
end

class MinimalAttachment < ActiveRecord::Base
  is_attachment
end

class DbBackedAttachment < ActiveRecord::Base
  is_attachment :storage_engine => :db
end

class MiniMagickAttachment < ActiveRecord::Base
  is_attachment :image_engine => :mini_magick, :image_versions => {:custom => :custom}

  def custom(img)
    img
  end
end

class AttachmentWithImageVersions < Attachment
  is_attachment :image_versions => { :thumb => '50' }
end

class AttachmentWithDeclarationTwice < Attachment
  is_attachment :image_versions => { :thumb => '50' }
  is_attachment :image_versions => { :custom => '50' }
end

class AttachmentWithCustomImageVersions < Attachment
  is_attachment :image_versions => { :custom => :custom }

  def custom(img)
    img.thumbnail(50,50)
  end
end

class BackgroundRbProcessedAttachments < ActiveRecord::Base
  is_attachment :backgroundrb => true, :image_versions => {:thumb => 50, :big_thumb => 90}
end

class AttachmentWithCropperVersions < Attachment
  is_attachment :image_versions => { :cropped => PeelMeAGrape::IsAttachment::Transformer::Cropper.new(50,60), :big_cropped => {:cropper => {:width => 500, :height => 600}}, :medium_cropped => {:cropper => [250,300]}}
end