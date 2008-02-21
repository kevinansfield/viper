require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))

module PeelMeAGrape::IsAttachment::Storage
  class FileSystemTest < Test::Unit::TestCase
    def setup
      @engine = FileSystem.new(Attachment)
      @attachment = Attachment.new
      @attachment.is_attachment_storage_engine = @engine
    end

    def test_copy_to_temp_file
      @attachment.stubs(:id).returns(13)
      @attachment.uploaded_data = text_upload
      @engine.persist_to_storage(@attachment)
      temp_file = @engine.copy_to_temp_file(@attachment)
      assert_equal "text_upload file contents", File.read(temp_file.path)
      assert_file? @engine.full_filename(@attachment)
      assert_file? temp_file.path
      assert_not_equal temp_file.path, @engine.full_filename(@attachment)
    end

    def test_persist_to_storage
      @attachment.uploaded_data = image_upload
      @engine.persist_to_storage(@attachment)
      assert_file? @engine.full_filename(@attachment)
      assert_equal File.size(@engine.full_filename(@attachment)), @attachment.file_size
    end

    def test_remove_from_storage
      @attachment.uploaded_data = image_upload
      @attachment.save!
      path = @engine.full_filename(@attachment)
      dirname = File.dirname(path)
      assert_file? path
      assert_directory? dirname
      @engine.remove_from_storage(@attachment)
      assert_not_file? path
      assert_not_directory? dirname
    end

    def test_remove_from_storage_other_files_in_directory
      @attachment.uploaded_data = image_upload
      @attachment.save!
      path = @engine.full_filename(@attachment)
      second_path = path.to_s + '.tmp'
      FileUtils.cp(path, second_path)
      assert_file? path
      @attachment.remove_from_storage
      assert_not_file? path
      assert_file? second_path
    end

    def test_remove_from_storage_fails_throws_nothing
      @attachment.uploaded_data = image_upload
      @attachment.save!
      File.open(@engine.full_filename(@attachment), 'w')
      assert_nothing_raised {@engine.remove_from_storage(@attachment) }
    end

    def test_attachment_dir_for_versions
      @attachment.stubs(:id).returns(12)
      @attachment.version_name = 'custom'
      @attachment.filename = 'rails_custom.png'
      assert_equal 12, @engine.attachment_dir_id(@attachment)
      assert_equal File.join(PeelMeAGrape::IsAttachment.file_storage_base_path, 'attachments', '12', 'rails_custom.png'), @engine.full_filename(@attachment)
      assert_equal File.join('attachments', '12'), @engine.attachment_dir(@attachment)
    end

    def test_attachment_dir_for_sub_classes
      @attachment = AttachmentWithImageVersions.new(:filename => 'rails.png')
      @attachment.base_version_id = 12
      @attachment.stubs(:id).returns(13)
      assert_equal 12, @engine.attachment_dir_id(@attachment)
      assert_equal File.join('attachments', '12'), @engine.attachment_dir(@attachment)
    end

    def test_file_paths_computed_with_different_base_paths
      default_base_path = File.join(RAILS_ROOT, 'public')
      PeelMeAGrape::IsAttachment.file_storage_base_path = default_base_path
      @attachment.stubs(:id).returns(13)
      @attachment.stubs(:filename).returns("rails.png")
      assert_equal File.join('attachments', '13'), @engine.attachment_dir(@attachment)
      assert_equal File.join(default_base_path, 'attachments', '13', 'rails.png'), @engine.full_filename(@attachment)
      assert_equal File.join(default_base_path, 'attachments', '13', 'rails_thumb.png'), @engine.full_filename(@attachment, :thumb)
      assert_equal File.join('/attachments', '13', 'rails.png'), @engine.public_path(@attachment)
      assert_equal File.join('/attachments', '13', 'rails_thumb.png'), @engine.public_path(@attachment, :thumb)

      alternative_base_path = File.join(RAILS_ROOT, 'public', 'i')
      PeelMeAGrape::IsAttachment.file_storage_base_path = alternative_base_path
      assert_equal File.join('/i/attachments', '13', 'rails.png'), @engine.public_path(@attachment)
      assert_equal File.join(alternative_base_path, 'attachments', '13', 'rails.png'), @engine.full_filename(@attachment)
      assert_equal File.join(alternative_base_path, 'attachments', '13', 'rails_thumb.png'), @engine.full_filename(@attachment, :thumb)
      assert_equal File.join('attachments', '13'), @engine.attachment_dir(@attachment)
    end
  end
end