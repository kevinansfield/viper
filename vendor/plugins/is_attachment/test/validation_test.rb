require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class AttachmentWithDefaultValidations < Attachment
end

class AttachmentWithNonAttachmentValidations < Attachment
  validates_length_of :other_column, :minimum => 5
  is_attachment :validate => {:content_type => :image, :file_extension => '.png' }
end

class MinimalAttachmentWithValidations < MinimalAttachment
  is_attachment :validate => {:max_file_size => 80.kilobytes}
end

class AttachmentWithValidations < Attachment
  is_attachment :validate => {:width => 50}
end

class AttachmentWithAllPossibleValidations < Attachment
  is_attachment :validate => {:width => 50, :min_width => 20, :max_width => 60, :height => 50, :min_height => 20, :max_height => 60,  :file_size => 50, :max_file_size => 60, :required => true, :content_type => :image, :file_extension => '.png' }
end

class ValidationTest < Test::Unit::TestCase
  def setup
    AttachmentWithValidations.validate_options = {:required => true, :width => 50} # messy.... do something like with_validate_options do .... end
    @attachment = AttachmentWithValidations.new(:width => 50, :filename => 'blah')
    @model = AttachmentWithValidations.new(:width => 50, :height => 50, :file_size => 50, :content_type => 'image/png', :filename => 'blah.png')
    @model.upload_to_process = true
  end

  def test_validates_base_version
    @attachment.expects(:is_base_version?).returns(true)
    @attachment.expects(:validate_attachment)
    @attachment.valid?
  end

  def test_doesnt_validate_derived_versions
    @attachment.expects(:is_base_version?).returns(false)
    @attachment.expects(:validate_attachment).never
    @attachment.valid?
  end

  def test_only_validate_required_called_if_no_upload_to_process
    @model.expects(:upload_to_process?).returns(true)
    @model.expects(:validate_required)
    [:validate_width_height_and_file_size, :validate_min_width_and_height, :validate_max_width_height_and_file_size, :validate_content_type].each do |validate_method|
      @model.expects(validate_method)
    end
    @model.valid?
  end

  def test_all_validate_methods_called_when_file_uploaded
    @model.expects(:upload_to_process?).returns(false)
    @model.expects(:validate_required)
    [:validate_width_height_and_file_size, :validate_min_width_and_height, :validate_max_width_height_and_file_size, :validate_content_type].each do |validate_method|
      @model.expects(validate_method).never
    end
    @model.valid?
  end

  def test_validate_required
    @model.expects(:has_attachment?).returns(false).at_least_once
    @model.validate_options[:required] = true
    @model.expects(:upload_to_process?).returns(true).at_least_once
    assert @model.valid?
    @model.expects(:upload_to_process?).returns(false).at_least_once
    assert !@model.valid?
    assert_equal "requires file to be uploaded", @model.errors.on(:uploaded_data)
    @model.validate_options[:required] = false
    @model.expects(:upload_to_process?).returns(true).at_least_once
    assert @model.valid?
    @model.expects(:upload_to_process?).returns(false).at_least_once
    assert @model.valid?
    @model = AttachmentWithValidations.new
    @attachment.validate_options[:required] = false
    assert @attachment.valid?

    @model.expects(:has_attachment?).returns(true)
    @model.validate_options[:required] = true
    assert @model.valid?
  end
  
  def test_validate_attachment_calls_clear_existing_temp_file_if_some_validations_fail
    @model.expects(:clear_existing_temp_file).never
    @model.clear_temp_path_if_validations_fail {}

    @model.expects(:clear_existing_temp_file)
    @model.clear_temp_path_if_validations_fail do
      @model.errors.add(:filename, "must exist")
    end

    @model.expects(:clear_temp_path_if_validations_fail)
    @model.expects(:upload_to_process?).returns(true).at_least_once
    @model.validate_attachment
  end

  def test_validate_required_passes_when_already_has_file_uploaded
    @model = AttachmentWithDefaultValidations.new
    @model.filename = "somefile.jpg"
    assert_equal "somefile.jpg", @model.filename
    @model.update_attributes!(:other_column => 'Some Value')
    assert @model.valid?
    assert_equal "somefile.jpg", @model.filename
  end

  def test_skip_some_attachment_validations_when_already_uploaded_path_successfully_set
    # idea here is that validations against width,height,content_type shouldn't fail second time around - they have already passed to get this far
    File.expects(:file?).returns(true)
    @model = AttachmentWithNonAttachmentValidations.new
    @model.stubs(:clear_existing_temp_file)
    @model.filename = "somefile.jpg"
    @model.already_uploaded_data = "some_path_well_fake_to_work"
    assert !@model.valid?
    @model.other_column = "123456"
    assert @model.valid?
  end

  def test_validates_required_by_default
    assert_equal true, AttachmentWithDefaultValidations.validate_options[:required]
  end

  def test_validates_can_validate_file_size_when_no_file_size_column
    @model = MinimalAttachmentWithValidations.new(:file_size => 50.kilobytes)
    @model.upload_to_process = true
    assert_validation :file_size, 10, 50.kilobytes
    assert_invalidation :file_size, 90.kilobytes
  end

  def test_validate_content_type
    @model.validate_options[:content_type] = 'image/png'
    assert_validation :content_type, 'image/png'
    assert_invalidation :content_type, 'should be image/png', 'image/jpeg', 'image/gif'
    @model.validate_options[:content_type] = :image
    assert_validation :content_type, PeelMeAGrape::IsAttachment.image_content_types.flatten
    assert_invalidation :content_type, 'should be one of (image/jpeg, image/pjpeg, image/gif, image/png, image/x-png)', 'application/pdf', 'application/ogg'
    @model.validate_options[:content_type] = ['image/png', 'image/jpeg']
    assert_validation :content_type, 'image/png', 'image/jpeg'
    assert_invalidation :content_type, 'should be one of (image/png, image/jpeg)', 'image/gif', 'application/ogg'
    @model.validate_options[:content_type] = [:image, 'application/ogg']
    assert_validation :content_type, PeelMeAGrape::IsAttachment.image_content_types.flatten, 'application/ogg'
    assert_invalidation :content_type, 'should be one of (application/ogg, image/jpeg, image/pjpeg, image/gif, image/png, image/x-png)', 'application/pdf'
    @model.validate_options[:content_type] = nil
    assert_validation :content_type, PeelMeAGrape::IsAttachment.image_content_types.flatten, 'application/ogg', nil
  end

  def test_validate_filename_extension
    @model.expects(:filename_extension).returns('png').at_least_once
    @model.validate_options[:file_extension] = 'png'
    assert @model.valid?
    @model.validate_options[:file_extension] = '.png'
    assert @model.valid?

    @model.expects(:filename_extension).returns('jpg')
    @model.validate_options[:file_extension] = 'png'
    assert !@model.valid?
    assert_equal "must be 'png'", @model.errors.on(:file_extension)
  end

  def test_validate_max_width_height_or_file_size
    check_validates_against_maximum(:width, :height, :file_size)
  end

  def test_validate_min_width_height
    check_validates_against_minimum(:width, :height)
  end

  def test_validate_width_height_and_file_size
    check_validates_against_fixnum_or_range(:width, :height, :file_size)
  end

  def check_validates_against_minimum(*attributes)
    @model = AttachmentWithValidations.new(:width => 50, :height => 50, :filename => 'blah.jpg')
    @model.validate_options[:width] = nil
    @model.upload_to_process = true
    attributes.each do |attribute|
      @model.validate_options["min_#{attribute.to_s}".to_sym] = 40
      assert_validation attribute, 50, 40, 400
      assert_invalidation attribute, 'must be at least 40', nil, 39, 0, 1
      @model.validate_options["min_#{attribute.to_s}".to_sym] = nil
      assert_validation attribute, 1, 50, 40, 400
    end
  end

  def check_validates_against_maximum(*attributes)
    @model = AttachmentWithValidations.new(:width => 30, :height => 30, :file_size => 30, :filename => 'blah.jpg' )
    @model.validate_options[:width] = nil
    @model.upload_to_process = true
    attributes.each do |attribute|
      @model.validate_options["max_#{attribute.to_s}".to_sym] = 40
      assert_validation attribute, 40, 39, 1
      assert_invalidation attribute, "can't be more than 40", 41, 10000
      @model.validate_options["max_#{attribute.to_s}".to_sym] = nil
      assert_validation attribute, 1, 50, 40, 400, 100000
    end
  end

  def check_validates_against_fixnum_or_range(*attributes)
    attributes.each do |attribute|
      @model.validate_options[attribute] = 50
      assert_validation attribute, 50
      assert_invalidation attribute, 'should be exactly 50', nil, 49, 51, 0
      @model.validate_options[attribute] = (1..50)
      assert_validation attribute, 50, 1, 34
      assert_invalidation attribute, 'should be between 1 and 50', nil, 0, 51, -1
      @model.validate_options[attribute] = nil
      assert_validation attribute, 50, 1, 34, 0, nil
    end
  end
end