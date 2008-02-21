require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class IsAttachmentTest < Test::Unit::TestCase
  def setup
    @attachment = Attachment.new
    @engine = Attachment.is_attachment_storage_engine
  end

  def test_attachments_directory_name
    assert_equal "minimal_attachments", MinimalAttachment.is_attachment_directory_name
    assert_equal "attachments", Attachment.is_attachment_directory_name
    assert_equal "attachments", AttachmentWithImageVersions.is_attachment_directory_name
    assert_equal "attachments", @attachment.is_attachment_directory_name
  end

  def test_temp_file_base_directory
    assert_equal File.join(PeelMeAGrape::IsAttachment.tempfile_path, Attachment.is_attachment_directory_name), Attachment.temp_file_base_directory
  end

  def test_already_uploaded_data
    @attachment.expects(:temp_path).returns(File.join(Attachment.temp_file_base_directory, "12345.6678.90", "my_upload.jpg")).times(2)
    assert_equal File.join("/12345.6678.90", "my_upload.jpg"), @attachment.already_uploaded_data
  end

  def test_already_uploaded_data_for_nil_temp_path
    @attachment.expects(:temp_path).returns(nil)
    assert_nil @attachment.already_uploaded_data
  end

  def test_responds_to_uploaded_data
    assert @attachment.respond_to?(:uploaded_data=)
    assert @attachment.respond_to?(:temp_path=)
    assert @attachment.respond_to?(:temp_path)
  end

  def test_stores_image_version_options
    assert_equal({ :thumb => '50' }, AttachmentWithImageVersions.image_version_options)
  end

  def test_image_version_option_for_version
    attachment = AttachmentWithImageVersions.new
    attachment.expects(:version_name).returns('thumb').at_least_once
    assert_equal '50', attachment.image_version_option
  end

  def test_defines_no_associations_if_no_versions
    @attachment = Attachment.new
    assert !@attachment.respond_to?(:versions)
    assert !@attachment.respond_to?(:base_version)
  end

  def test_defines_associations_when_versions
    @attachment = AttachmentWithImageVersions.new
    assert @attachment.respond_to?(:versions)
    assert @attachment.respond_to?(:base_version)
  end

  def test_is_attachment_declaration_twice
    @attachment = AttachmentWithDeclarationTwice.new
    assert_equal({:custom => '50'}, @attachment.image_version_options)
  end

  def test_is_base_version?
    assert @attachment.is_base_version?
    @attachment.base_version_id = 12
    assert !@attachment.is_base_version?
    @attachment = MinimalAttachment.new
    assert @attachment.is_base_version?
  end

  def test_responds_to_width_height_file_size_and_content_type_even_if_columns_not_there
    minimal = MinimalAttachment.new
    assert minimal.respond_to?(:width)
    assert minimal.respond_to?(:width=)
    assert minimal.respond_to?(:height)
    assert minimal.respond_to?(:height=)
    assert minimal.respond_to?(:content_type)
    assert minimal.respond_to?(:content_type=)
    assert minimal.respond_to?(:file_size)
    assert minimal.respond_to?(:file_size=)
  end

  def test_has_all_versions
    attachment = AttachmentWithImageVersions.new
    versions = attachment.versions
    attachment.expects(:is_base_version?).returns(true).at_least_once
    versions.expects(:size).returns(0)
    assert !attachment.has_all_versions?
    versions.expects(:size).returns(1)
    assert attachment.has_all_versions?
    attachment.expects(:is_base_version?).returns(false)
    versions.expects(:size).never
    assert attachment.has_all_versions?
  end

  def test_uploaded_data_sets_some_stuff_needs_width_or_height_before_validation
    @attachment.expects(:needs_width_or_height_before_validation?).returns(true)
    @attachment.uploaded_data = image_upload
    assert_equal 'rails.png', @attachment.filename
    assert_equal 50, @attachment.width
    assert_equal 64, @attachment.height
    assert_equal 50.0/64.0, @attachment.aspect_ratio
    assert_equal 'image/png', @attachment.content_type
    assert_equal File.size(image_upload.path), @attachment.file_size
  end

  def test_uploaded_data_sets_some_stuff_when_doesnt_need_width_or_height_before_validation
    @attachment.expects(:needs_width_or_height_before_validation?).returns(false)
    @attachment.uploaded_data = image_upload
    assert_equal 'rails.png', @attachment.filename
    assert_nil @attachment.width
    assert_nil @attachment.height
    assert_nil @attachment.aspect_ratio
    assert_equal 'image/png', @attachment.content_type
    assert_equal File.size(image_upload.path), @attachment.file_size
  end

  def test_raises_if_uploaded_data_assigned_a_string
    assert_raises(TypeError, ":uploaded_data should be assigned a file - you passed a String. Check if the form's encoding has been set to 'multipart/form-data'."){@attachment.uploaded_data = "path_to_file"}
  end

  def test_filename_attribute_protected
    @model = Attachment.new
    @model.attributes = {:other_column => 'Some Value', :filename => 'cheeky.jpg'}
    assert @model.filename.nil?

    @model.filename = 'granted.jpg'
    @model.attributes = {:other_column => 'Some Value', :filename => 'still_cheeky.jpg'}
    assert_equal 'granted.jpg', @model.filename
  end

  def test_file_size_on_minimal_attachment
    @attachment = MinimalAttachment.new
    @attachment.uploaded_data = image_upload
    assert_equal File.size(image_upload.path), @attachment.file_size
  end

  def test_upload_text_file
    @attachment.uploaded_data = text_upload
    assert_equal 'text/plain', @attachment.content_type
    assert_equal 'simple.txt', @attachment.filename
    assert_equal File.size(text_upload.path), @attachment.file_size
    assert_nil @attachment.width
    assert_nil @attachment.height
  end

  def test_uploaded_data_has_value_of_nil
    assert_nil @attachment.uploaded_data
    @attachment.uploaded_data = text_upload
    assert_nil @attachment.uploaded_data
  end

  def test_uploaded_data_assigned_nil
    @attachment.uploaded_data = nil
    assert_nil @attachment.temp_path
  end

  def test_uploaded_data_ignores_empty_file
    @attachment.uploaded_data = fixture_file_upload('/files/empty.txt', 'text/plain')
    assert_nil @attachment.temp_path
  end

  def test_strips_content_type
    @upload = fixture_file_upload('/files/simple.txt')
    @upload.expects(:content_type).returns("text/plain\r")
    @attachment.uploaded_data = @upload
    assert_equal 'text/plain', @attachment.content_type
  end

  def test_upload_to_minimal_attachment_table
    @attachment = MinimalAttachment.new
    @attachment.uploaded_data = image_upload
    assert_equal 'rails.png', @attachment.filename
  end

  def test_upload_data_as_string_io
    @attachment = MinimalAttachment.new
    @string_io_upload = fixture_file_string_io_upload('/files/simple.txt', 'text/plain')
    @attachment.uploaded_data = @string_io_upload
    assert_equal 'simple.txt', @attachment.filename
    assert_equal fixture_file_upload('/files/simple.txt', 'text/plain').read, File.read(@attachment.temp_path)
  end

  def test_set_width_and_height_from_image
    @attachment.expects(:image?).returns(true).at_least_once
    with_mock_img(@attachment) do |img|
      @attachment.expects(:grab_dimensions_from_image).with(img)
      @attachment.set_width_and_height_from_image
    end
  end

  def test_assign_file_name_sanitizes
    assert_sanitizes_file_name 'rails.png', 'files/rails.png'
    assert_sanitizes_file_name 'rails.png', 'fixtures/files\\rails.png'
    assert_sanitizes_file_name 'r_a_l_-.png', '/files\\r a!l*-.png'
  end

  def assert_sanitizes_file_name(expected_sanitized, original_filename)
    @attachment.filename = original_filename
    assert_equal expected_sanitized, @attachment.filename
  end

  def test_uploaded_data_copies_to_new_temp_path
    upload = image_upload
    @attachment.uploaded_data = upload
    assert_not_equal upload.path, @attachment.temp_path
  end

  def test_temp_data
    @attachment.uploaded_data = text_upload
    assert_equal 'text_upload file contents', @attachment.temp_data
  end

  def test_dir_empty?
    assert Dir.empty?(File.join(Test::Unit::TestCase.fixture_path, 'files', 'empty'))
    assert !Dir.empty?(File.join(Test::Unit::TestCase.fixture_path, 'files'))
  end

  def test_with_base_version_validations
    Attachment.expects(:with_options).with(:if => PeelMeAGrape::IsAttachment.check_is_base_version_proc )
    Attachment.with_base_version_validations
  end

  def test_image_size
    assert_nil @attachment.image_size
    @attachment.width = 50; @attachment.height = 80
    assert_equal "50x80", @attachment.image_size
    assert_nil MinimalAttachment.new.image_size
  end


  def test_image?
    @attachment.filename = ""
    PeelMeAGrape::IsAttachment.image_content_types.each do |content_type|
      @attachment.content_type = content_type
      assert @attachment.image?, "Expected to recognise #{content_type} as image?"
    end
    [nil, '', 'text/plain'].each do |content_type|
      @attachment.content_type = content_type
      assert !@attachment.image?, "Expected not to recognise #{content_type} as image?"
    end
    @attachment.filename = "sample.jpg"
    @attachment.content_type = 'image/jpeg'
    assert @attachment.image?
  end

  def test_image_with_fallback_to_file_extension
    @attachment = MinimalAttachment.new
    PeelMeAGrape::IsAttachment.image_file_extensions.each do |ext|
      @attachment.filename = "image.#{ext}"
      assert @attachment.image?, "Expected to recognise .#{ext} as image?"
    end
    ['', 'txt', 'doc'].each do |ext|
      @attachment.filename = "image.#{ext}"
      assert !@attachment.image?, "Expected not to recognise #{ext} as image?"
    end
  end

  def test_filename_extension
    {"file" => nil, "file.txt"=> 'txt', "file.txt.doc"=> 'doc'}.each do |filename, expected_extension|
      @attachment.expects(:filename).returns(filename)
      assert_equal expected_extension, @attachment.filename_extension
    end
  end

  def test_file_name_for_version
    @attachment.filename = 'rails.png'
    assert_equal 'rails.png',             @attachment.file_name_for_version(nil)
    assert_equal 'rails.png',             @attachment.file_name_for_version('')
    assert_equal 'rails_blah.png',        @attachment.file_name_for_version(:blah)
    assert_equal 'rails_blah.blah.png',   @attachment.file_name_for_version('blah.blah')
    assert_equal 'rails_blah._blah_.png', @attachment.file_name_for_version('blah._blah_')
    @attachment.filename = 'rails.logo.png'
    assert_equal 'rails.logo_blah.png',   @attachment.file_name_for_version(:blah)
  end

  def test_persist_to_storage_calls_through_to_storage_engine
    @attachment.is_attachment_storage_engine.expects(:persist_to_storage).with(@attachment)
    @attachment.persist_to_storage
  end

  def test_remove_from_storage_calls_through_to_storage_engine
    @attachment.is_attachment_storage_engine.expects(:remove_from_storage).with(@attachment)
    @attachment.remove_from_storage
  end

  def test_remove_from_storage_calls_through_to_storage_engine
    @attachment.is_attachment_storage_engine.expects(:copy_to_temp_file).with(@attachment)
    @attachment.copy_to_temp_file
  end

  def test_remove_from_storage_calls_through_to_storage_engine
    @attachment.is_attachment_storage_engine.expects(:public_path).with(@attachment, :thumb)
    @attachment.public_path(:thumb)
    @attachment.is_attachment_storage_engine.expects(:public_path).with(@attachment, nil)
    @attachment.public_path
  end

  def test_with_image_calls_through_to_image_engine
    @attachment.is_attachment_image_engine.expects(:with_image).with(@attachment) { true }
    @attachment.with_image {}
  end

  def test_with_image_then_inspect_calls_through_to_image_engine
    @attachment.is_attachment_image_engine.expects(:with_image_then_inspect).with(@attachment) { true }
    @attachment.with_image_then_inspect {}
  end

  def test_transform_image_at_temp_path_calls_through_to_image_engine
    @attachment.is_attachment_image_engine.expects(:transform_image_at_temp_path).with(@attachment)
    @attachment.transform_image_at_temp_path
  end

  def test_grab_dimensions_from_image_calls_through_to_image_engine
    img = stub(:columns => 10, :rows => 5)
    @attachment.is_attachment_image_engine.expects(:grab_dimensions_from_image).with(@attachment, img)
    @attachment.grab_dimensions_from_image(img)
  end

  def test_reprocess_attachment_on_version_process_from_base_version
    @attachment.expects(:is_base_version?).returns(false)
    @attachment.expects(:process_from_base_version)
    @attachment.reprocess_attachment
  end

  def test_reprocess_attachment_on_base_reprocess_base_version
    @attachment.expects(:is_base_version?).returns(true)
    @attachment.expects(:reprocess_base_version)
    @attachment.reprocess_attachment
  end

  def test_reprocess_all
    Attachment.expects(:find).with(:all, :conditions => {:base_version_id => nil}).returns([mock(:reprocess_attachment => true), mock(:reprocess_attachment => true)])
    Attachment.reprocess_all_attachments
  end

  def test_reprocess_all_on_attachment_without_versions
    assert_nothing_raised {MinimalAttachment.reprocess_all_attachments}
  end

  def test_needs_width_or_height_before_validation?
    @attachment.expects(:validate_options).returns({})
    assert !@attachment.needs_width_or_height_before_validation?
    @attachment.expects(:validate_options).returns({:width => 50})
    assert @attachment.needs_width_or_height_before_validation?
    @attachment.expects(:validate_options).returns({:height => 50})
    assert @attachment.needs_width_or_height_before_validation?
    @attachment.expects(:validate_options).returns({:min_height => 50})
    assert @attachment.needs_width_or_height_before_validation?
    @attachment.expects(:validate_options).returns({:max_width => 50})
    assert @attachment.needs_width_or_height_before_validation?
  end

  def test_has_attachment?
    @attachment.expects(:filename).returns("some_upload.jpg")
    assert @attachment.has_attachment?
    @attachment.expects(:filename).returns(nil)
    assert !@attachment.has_attachment?
  end

  def test_assigning_uploaded_calls_clear_existing_temp_file
    @attachment.expects(:clear_existing_temp_file)
    @attachment.uploaded_data = text_upload
  end

  def test_clear_existing_temp_file
    @attachment.expects(:temp_path).returns(nil)
    @attachment.expects(:temp_path=).never
    FileUtils.expects(:rm_rf).never
    @attachment.clear_existing_temp_file

    temp_path = "/random/upload/dir/upload.jpg"
    @attachment.expects(:temp_path).returns(temp_path).at_least_once
    @attachment.expects(:temp_path=).with(nil)
    FileUtils.expects(:rm_rf).with(File.dirname(temp_path))
    @attachment.clear_existing_temp_file
  end
end