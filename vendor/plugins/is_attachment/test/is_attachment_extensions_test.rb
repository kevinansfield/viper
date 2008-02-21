require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class IsAttachmentExtensionsTest < Test::Unit::TestCase
  def test_file_system_storage_included_by_default
    assert Attachment.is_attachment_storage_engine.is_a?(PeelMeAGrape::IsAttachment::Storage::FileSystem)
  end

  def test_configure_included_storage_engine
    assert DbBackedAttachment.is_attachment_storage_engine.is_a?(PeelMeAGrape::IsAttachment::Storage::Db)
  end

  def test_configure_storage_engine
    assert PeelMeAGrape::IsAttachment.respond_to?(:storage_engines)
    assert !PeelMeAGrape::IsAttachment.respond_to?(:storage_engines=)
    assert PeelMeAGrape::IsAttachment.respond_to?(:default_storage_engine)
    assert PeelMeAGrape::IsAttachment.respond_to?(:default_storage_engine=)
    assert_equal :file_system, PeelMeAGrape::IsAttachment.default_storage_engine
  end

  def test_raises_if_new_default_not_valid_storage_engine
    assert_raises(PeelMeAGrape::IsAttachment::UnregisteredExtensionError) do
      PeelMeAGrape::IsAttachment.default_storage_engine = :bad_engine
    end
  end

  def test_rmagick_image_engine_included_by_default
    assert Attachment.is_attachment_image_engine.is_a?(PeelMeAGrape::IsAttachment::Image::Rmagick)
  end

  def test_configure_image_engine
    assert MiniMagickAttachment.is_attachment_image_engine.is_a?(PeelMeAGrape::IsAttachment::Image::MiniMagick)
  end

  def test_configure_image_engine
    assert PeelMeAGrape::IsAttachment.respond_to?(:image_engines)
    assert !PeelMeAGrape::IsAttachment.respond_to?(:image_engines=)
    assert PeelMeAGrape::IsAttachment.respond_to?(:default_image_engine)
    assert PeelMeAGrape::IsAttachment.respond_to?(:default_image_engine=)
    assert_equal :mini_magick, PeelMeAGrape::IsAttachment.default_image_engine
  end

  def test_bad_default_image_engine
    assert_raises(PeelMeAGrape::IsAttachment::UnregisteredExtensionError) do
      PeelMeAGrape::IsAttachment.default_image_engine = :bad_engine
    end
  end

  def test_registered_transformers
    assert PeelMeAGrape::IsAttachment.respond_to?(:custom_transformers)
    assert !PeelMeAGrape::IsAttachment.respond_to?(:custom_transformers=)
    assert_equal(PeelMeAGrape::IsAttachment::Transformer::Cropper, PeelMeAGrape::IsAttachment.custom_transformers[:cropper])
  end

  def test_register_new_transformer
    assert PeelMeAGrape::IsAttachment.respond_to?(:register_transformer)
    bad_custom_transformer = mock("bad_custom_transformer", :ancestors => [])
    valid_custom_transformer = Class.new(PeelMeAGrape::IsAttachment::Transformer::Base)
    assert_raises(PeelMeAGrape::IsAttachment::BadExtensionClassError, "Expected Class of type PeelMeAGrape::IsAttachment::Transformer::Base") do
      PeelMeAGrape::IsAttachment.register_transformer(:new_transformer, bad_custom_transformer)
      assert !PeelMeAGrape::IsAttachment.custom_transformers.keys.include?(:new_transformer)
    end
    assert_raises(ArgumentError, "expected to be a Class - not an instance of one") do
      PeelMeAGrape::IsAttachment.register_transformer(:new_transformer, valid_custom_transformer.new)
    end
    assert_nothing_raised {PeelMeAGrape::IsAttachment.register_transformer(:new_transformer, valid_custom_transformer)}
    assert_equal valid_custom_transformer, PeelMeAGrape::IsAttachment.custom_transformers[:new_transformer]
  end

  def test_configure_custom_transformers
    image_version = AttachmentWithCropperVersions.image_version_options[:cropped]
    assert image_version.is_a?(PeelMeAGrape::IsAttachment::Transformer::Cropper)
    assert image_version.is_a?(PeelMeAGrape::IsAttachment::Transformer::Base)
    assert_equal 50, image_version.width
    assert_equal 60, image_version.height
  end

  def test_cropper_should_add_extra_methods_to_base
    assert !Attachment.included_modules.include?(PeelMeAGrape::IsAttachment::Transformer::Cropper::InstanceMethods)
    assert AttachmentWithCropperVersions.included_modules.include?(PeelMeAGrape::IsAttachment::Transformer::Cropper::InstanceMethods)
    assert AttachmentWithCropperVersions.new.respond_to?(:cropper_restrictions)
    assert !Attachment.new.respond_to?(:cropper_restrictions)
  end

  def test_register_storage_engine
    assert PeelMeAGrape::IsAttachment.respond_to?(:register_storage_engine)

    invalid_storage_engine = Object.const_set(:InvalidStorageEngine, Class.new(String)) unless Object.const_defined?(:InvalidStorageEngine)
    valid_storage_engine = Object.const_set(:ValidStorageEngine, Class.new(PeelMeAGrape::IsAttachment::Storage::Base)) unless Object.const_defined?(:ValidStorageEngine)

    assert_raises(PeelMeAGrape::IsAttachment::BadExtensionClassError, "Expected Class of type PeelMeAGrape::IsAttachment::Storage::Base") do
      PeelMeAGrape::IsAttachment.register_storage_engine(:new_engine, invalid_storage_engine)
      assert !PeelMeAGrape::IsAttachment.storage_engines.keys.include?(:new_engine)
    end
    assert_nothing_raised {PeelMeAGrape::IsAttachment.register_storage_engine(:new_engine, valid_storage_engine)}
    assert_equal valid_storage_engine, PeelMeAGrape::IsAttachment.storage_engines[:new_engine]
  end

  def test_register_image_engine
    assert PeelMeAGrape::IsAttachment.respond_to?(:register_image_engine)
    invalid_image_engine = Object.const_set(:InvalidImageEngine, Class.new(String)) unless Object.const_defined?(:InvalidImageEngine)

    assert_raises(PeelMeAGrape::IsAttachment::BadExtensionClassError, "Expected Class of type PeelMeAGrape::IsAttachment::Image::Base") do
      PeelMeAGrape::IsAttachment.register_image_engine(invalid_image_engine)
      assert !PeelMeAGrape::IsAttachment.image_engines.keys.include?(:my_invalid_image_engine)
    end

    valid_image_engine = Object.const_set(:ValidImageEngine, Class.new(PeelMeAGrape::IsAttachment::Image::Base)) unless Object.const_defined?(:ValidImageEngine)
    valid_image_engine.expects(:name).returns(:my_valid_image_engine)

    PeelMeAGrape::IsAttachment.register_image_engine(valid_image_engine)
    assert_equal valid_image_engine, PeelMeAGrape::IsAttachment.image_engines[:my_valid_image_engine]
    assert PeelMeAGrape::IsAttachment.image_engines.keys.include?(:my_valid_image_engine)
  end
end