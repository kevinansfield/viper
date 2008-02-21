require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

class ActiveRecord::Base
  public :callback
end

class IsAttachmentLifecycleTest < Test::Unit::TestCase
  def setup
    @attachment = Attachment.new
  end

  def test_after_save_calls_process_base_version
    @attachment.validate_options[:required] = false
    @attachment.expects(:process_base_version)
    @attachment.expects(:process_from_base_version_without_check_not_base_version).never
    @attachment.callback(:after_save)
  end

  def test_process_from_base_version_checks_its_not_base_version
    @attachment.expects(:is_base_version?).returns(true)
    @attachment.expects(:transform_base_version_image).never
    @attachment.expects(:persist_to_storage_if_new_file_attached).never
    @attachment.process_from_base_version

    @attachment.expects(:is_base_version?).returns(false)
    @attachment.expects(:transform_base_version_image)
    @attachment.expects(:persist_to_storage_if_new_file_attached)
    @attachment.process_from_base_version
  end

  def test_before_save_calls_process_from_base_version
    @attachment.expects(:process_from_base_version)
    @attachment.callback(:before_save)
  end
  
  def test_process_from_base_version
    @attachment.expects(:is_base_version?).returns(false)
    @attachment.expects(:transform_base_version_image)
    @attachment.expects(:persist_to_storage_if_new_file_attached)
    @attachment.process_from_base_version
    @attachment.expects(:is_base_version?).returns(true)
    @attachment.expects(:transform_base_version_image).never
    @attachment.expects(:persist_to_storage_if_new_file_attached).never
    @attachment.process_from_base_version
  end

  def test_process_base_version_with_check_if_upload_to_process
    @attachment.expects(:persist_to_storage_if_new_file_attached)
    @attachment.expects(:upload_to_process?).returns(true)
    @attachment.expects(:image?).returns(false)
    @attachment.expects(:is_base_version?).returns(true)
    @attachment.process_base_version
  end

  def test_process_base_version_with_no_upload_to_process
    @attachment.expects(:image_version_options).never
    @attachment.expects(:upload_to_process?).returns(false)
    @attachment.expects(:is_base_version?).returns(true)
    @attachment.process_base_version
  end

  def test_process_base_version_not_base_version
    @attachment.expects(:persist_to_storage_if_new_file_attached).never
    @attachment.expects(:is_base_version?).returns(false)
    @attachment.process_base_version
  end

  def test_process_base_version_sets_width_and_height_when_doesnt_need_width_or_height_before_validation
    @attachment.expects(:needs_width_or_height_before_validation?).returns(false)
    @attachment.expects(:update_width_and_height_from_image)
    @attachment.expects(:image?).returns(true)
    @attachment.expects(:upload_to_process?).returns(true)
    @attachment.expects(:is_base_version?).returns(true)
    @attachment.process_base_version
  end

  def test_process_base_version_sets_width_and_height_when_needs_width_or_height_before_validation
    @attachment.expects(:persist_to_storage_if_new_file_attached)
    @attachment.expects(:needs_width_or_height_before_validation?).returns(true)
    @attachment.expects(:update_width_and_height_from_image).never
    @attachment.expects(:image?).returns(true)
    @attachment.expects(:upload_to_process?).returns(true)
    @attachment.expects(:is_base_version?).returns(true)
    @attachment.process_base_version
  end

  def test_update_width_and_height_from_image
    @attachment.uploaded_data = image_upload
    @attachment.expects(:set_width_and_height_from_image)
    @attachment.class.expects(:update_all).with(["width = ?, height = ?, aspect_ratio = ?", @attachment.width, @attachment.height, @attachment.aspect_ratio], ["id = ?", @attachment.id])
    @attachment.update_width_and_height_from_image
  end

  def test_after_save_persist_to_storage_no_file_attached
    @attachment.expects(:persist_to_storage_if_new_file_attached)
    @attachment.expects(:persist_to_storage).never
    @attachment.callback(:after_save)
  end

  def test_after_save_persist_to_storage_file_attached
    @attachment.uploaded_data = image_upload
    @attachment.expects(:persist_to_storage)
    @attachment.callback(:after_save)
  end

  def test_after_destroy_remove_from_storage
    @attachment.expects(:remove_from_storage)
    @attachment.callback(:after_destroy)
  end

  def test_cascade_delete_records
    attachment = AttachmentWithImageVersions.new
    version = AttachmentWithImageVersions.new
    version.expects(:destroy)
    attachment.versions << version
    attachment.callback(:before_destroy)
  end
end