# Methods, specifically #validate_attachment, used to validate is_attachment models
module PeelMeAGrape::IsAttachment::Validation
  # performs all configured validations on your attachment
  def validate_attachment
    validate_required
    if new_upload_to_process?
      clear_temp_path_if_validations_fail do
        validate_width_height_and_file_size
        validate_min_width_and_height
        validate_max_width_height_and_file_size
        validate_content_type
        validate_file_extension
      end
    end
  end

  def clear_temp_path_if_validations_fail(&block)
    before = self.errors.count
    yield block
    after = self.errors.count
    self.clear_existing_temp_file unless before == after
  end

  protected
  # if :required is true - validation fails when no file received in uploaded_data
  # :required defaults to true
  def validate_required
    if validate_options[:required] && (!has_attachment? && !upload_to_process?)
      self.errors.add(:uploaded_data, "requires file to be uploaded")
    end
  end

  # validate :width and/or :height and/or :file_size against either a Fixnum or an Range
  def validate_width_height_and_file_size
    [:width, :height, :file_size].each do |attribute|
      validate_against = validate_options[attribute]
      value = self.send(attribute)
      if validate_against.is_a? Fixnum
        self.errors.add(attribute, "should be exactly #{validate_against}") if validate_against != value
      elsif validate_against.is_a? Range
        self.errors.add(attribute, "should be between #{validate_against.first} and #{validate_against.last}") unless validate_against.include?(value)
      elsif not validate_against.nil?
        raise ArgumentError.new("Validation options for #{attribute} must be eiter a Fixnum or a Range. It is a #{validate_against.class} - #{validate_against.inspect}")
      end
    end
  end

  # validate :width and/or height are at least a certain minimum value
  def validate_min_width_and_height
    [:width, :height ].each do |attribute|
      min_attribute = "min_#{attribute.to_s}".to_sym
      minimum_value = validate_options[min_attribute]
      unless minimum_value.blank?
        value = self.send(attribute)
        self.errors.add(attribute, "must be at least #{minimum_value}") if value.nil? || value < minimum_value
      end
    end
  end

  # validate :width and/or :height and/or :file_size are no greater than a particular maximum value.
  def validate_max_width_height_and_file_size
    [:width, :height, :file_size].each do |attribute|
      max_attribute = "max_#{attribute.to_s}".to_sym
      maximum_value = validate_options[max_attribute]
      unless maximum_value.blank?
        value = self.send(attribute)
        self.errors.add(attribute, "can't be more than #{maximum_value}") if value.nil? || value > maximum_value
      end
    end
  end

  # validate :content_type. can either be a string or an array of strings of valid content_types for the attachment. The symbol :image is expanded out to cover most common image file formats. (These are in the array - PeelMeAGrape::IsAttachment.image_content_types)
  def validate_content_type
    valid_content_types = validate_options[:content_type]
    unless valid_content_types.blank?
      valid_content_types = [valid_content_types] if valid_content_types.is_a?(String) || valid_content_types.is_a?(Symbol)
      if valid_content_types.include?(:image)
        valid_content_types.delete(:image)
        valid_content_types.concat(PeelMeAGrape::IsAttachment.image_content_types)
      end
      raise ArgumentError.new("Invalid content-type validation option - can be either a content_type string (eg application/pdf) or :image or and array of such.") unless valid_content_types.select{|c| c.is_a?(Symbol)}.empty?
      message = (valid_content_types.size > 1)? "should be one of (#{valid_content_types.join(', ')})" : "should be #{valid_content_types.join(', ')}"
      self.errors.add(:content_type, message) unless valid_content_types.include?(self.content_type)
    end
  end

  # validate :file_extension. must be a String. eg. 'png' 
  def validate_file_extension
    allowed_extension = validate_options[:file_extension]
    unless allowed_extension.nil?
      allowed_extension = allowed_extension[1..-1] if allowed_extension.starts_with?('.')
      self.errors.add(:file_extension, "must be '#{allowed_extension}'") if allowed_extension != self.filename_extension
    end
  end
end