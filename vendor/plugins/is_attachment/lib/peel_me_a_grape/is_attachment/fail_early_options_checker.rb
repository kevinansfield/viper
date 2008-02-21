# Class checks is_attachment options - raising errors if there are any problems.
class PeelMeAGrape::IsAttachment::FailEarlyOptionsChecker
  @@valid_keys = [:width, :height, :file_size, :content_type, :file_extension, :required, :min_width, :min_height, :max_width, :max_height, :max_file_size]

  # Catch configuration problems as early as possible.
  # will call #check_required_columns, #check_validate_keys, #check_validate_values, #check_storage_engine_options, #check_image_engine_options and #check_image_versions_options
  def self.check(model, options)
    options.assert_valid_keys(:image_versions, :validate, :file_param, :storage_engine, :image_engine, :backgroundrb)
    check_required_columns(model, options)
    check_validate_keys(options)
    check_validate_values(options)
    check_storage_engine_options(options)
    check_image_engine_options(options)
    check_image_versions_options(options)
  end

  # if the :storage_engine option is set - check that it is one of the registered storage engines. Raises PeelMeAGrape::IsAttachment::UnregisteredExtensionError if it isn't
  def self.check_storage_engine_options(options)
    engine_option = options[:storage_engine]
    unless engine_option.blank? || PeelMeAGrape::IsAttachment.storage_engines.keys.include?(engine_option)
      raise PeelMeAGrape::IsAttachment::UnregisteredExtensionError.new(":#{engine_option} is not a registered storage engine. Registered engines are (#{PeelMeAGrape::IsAttachment.storage_engines.keys.join(', ')})")
    end
  end

  # if the :image_engine option is set - check that it is one of the registered image engines. Raises PeelMeAGrape::IsAttachment::UnregisteredExtensionError if it isn't
  def self.check_image_engine_options(options)
    engine_option = options[:image_engine]
    unless engine_option.blank? || PeelMeAGrape::IsAttachment.image_engines.keys.include?(engine_option)
      raise PeelMeAGrape::IsAttachment::UnregisteredExtensionError.new(":#{engine_option} is not a registered image engine. Registered engines are (#{PeelMeAGrape::IsAttachment.image_engines.keys.join(', ')})") 
    end
  end

  # checks that the validate hash contains only valid keys
  # valid options are
  #    :width, :height, :file_size, :content_type, :required, :min_width, :min_height, :max_width, :max_height, :max_file_size
  def self.check_validate_keys(options)
    keys = (options[:validate] || {}).keys
    unknown_keys = keys - @@valid_keys
    raise(ArgumentError, "Invalid option(s) '#{unknown_keys.join(', ')}' for :validate - valid options are (#{@@valid_keys.join(', ')})") unless unknown_keys.empty?
  end

  # checks that the validate hash values are of the correct type
  # valid options are
  #    :width, :height, :file_size can be Range or Fixnum
  #    :min_width, :min_height must be Fixnum
  #    :max_width, :max_height, max_file_size must be Fixnum
  #    :required must be a boolean
  #    :content_type can be either a single string or symbol or and array of such. :image is the only allowed symbol.
  #    :file_extension must be a String. eg. '.jpg'
  def self.check_validate_values(options)
    validate_options = (options[:validate] || {})
    class_to_key = {String => [:file_extension], Range => [:width, :height, :file_size], Fixnum => [:width, :height, :file_size, :min_width, :min_height, :max_width, :max_height, :max_file_size], TrueClass => [:required], FalseClass => [:required]}
    content_type = validate_options[:content_type]
    content_type = [content_type] unless content_type.is_a?(Array)
    content_type.delete(:image)
    raise(ArgumentError, "Invalid content_type validation paramater") unless content_type.detect{|entry| !entry.is_a?(String)}.nil?
    validate_options.each do |key, value|
      next if key.eql?(:content_type)
      valid_entries = class_to_key[value.class]
      raise(ArgumentError, "Invalid Validation Paramater Type - (:#{key} - #{value.class})") if valid_entries.blank? || !valid_entries.include?(key)
    end
  end

  # checks that the minimum required columns are present on you model.
  # For an attachment with no versions only 'filename' is required.
  # For an attachment with versions 'base_version_id' and 'version_name' are also required.
  def self.check_required_columns(model, options)
    unless model.column_names.include?('filename')
      raise PeelMeAGrape::IsAttachment::AttachmentColumnsError.new("'is_attachment' requires at the very minimum a filename column")
    end
    if !options[:image_versions].blank?
      if !model.column_names.include?('base_version_id') || !model.column_names.include?('version_name')
        raise PeelMeAGrape::IsAttachment::AttachmentColumnsError.new("'is_attachment' requires the following columns (base_version_id, version_name) if your model creats multiple versions (ie. uses :image_versions option)")
      elsif !model.columns.detect{|col|col.name.to_s.eql?('version_name')}.text?
        raise PeelMeAGrape::IsAttachment::AttachmentColumnsError.new("'is_attachment' column :version_name must be of type :string")
      end 
    end
  end

  # checks that the image version options don't contain ambiguous hashed like
  #    :image_versions => {:thumb => {:cropper => 50, :cropper => 90}
  # and checks that if options are for a transformer that it exists
  #    :image_versions => {:thumb => {:custom_transformer => 50}
  # will check that PeelMeAGrape::IsAttachment.custom_transformers includes one for :custom_transformer
  def self.check_image_versions_options(options)
    image_version_options = options[:image_versions] || {}
    image_version_options.select{|k, v| v.is_a? Hash}.each do |key, value|
      raise ArgumentError.new("Ambiguous Configuration - hash should only contain one entry. #{value.keys.map(&:to_s).sort.map(&:to_sym).inspect}") if value.size > 1
      transformer_name = value.keys[0]
      raise ArgumentError.new("No Custom Transformer registered with name: '#{transformer_name}'") unless PeelMeAGrape::IsAttachment.custom_transformers.keys.include?(transformer_name)
    end
  end
end
