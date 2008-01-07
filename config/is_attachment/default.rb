# This file is loaded for all environments
# You can have environment specific configuration in file named like #{RAILS_ENV}.rb - eg. development.rb
# it will get loaded after this file

# PeelMeAGrape::IsAttachment.tempfile_path = '/tmp/is_attachment'
# PeelMeAGrape::IsAttachment.file_storage_base_path = File.join(RAILS_ROOT,'public','i',RAILS_ENV)
# PeelMeAGrape::IsAttachment.default_validations[:max_file_size] = 256.kilobytes
PeelMeAGrape::IsAttachment.default_image_engine = :rmagick