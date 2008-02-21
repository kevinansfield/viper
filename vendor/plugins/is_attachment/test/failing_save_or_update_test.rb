require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

module PeelMeAGrape::IsAttachment
  class FailingSaveOrUpdateTest < Test::Unit::TestCase
    include FileHelper

    def setup
      @attachment = Attachment.new
      @engine = @attachment.is_attachment_storage_engine
      @temp_dir_base = File.expand_path(File.join(PeelMeAGrape::IsAttachment.tempfile_path, Attachment.is_attachment_directory_name))
      @temp_dir = File.join(@temp_dir_base, "12345.678.9")
      FileUtils.mkdir_p(@temp_dir)
      @temp_file = File.join(@temp_dir, "simple.txt")
      @already_uploaded_path = relative_path(@temp_dir_base, @temp_file)
      FileUtils.copy_file(text_upload.path, @temp_file)
    end

    def test_create_with_already_uploaded_data
      attachment = Attachment.new(:already_uploaded_data => @already_uploaded_path)
      assert_equal @temp_file, attachment.temp_path
      assert attachment.upload_to_process?
    end

    def test_create_with_already_uploaded_data_and_new_uploaded_data
      attachment = Attachment.new(:already_uploaded_data => @already_uploaded_path, :uploaded_data => image_upload)
      assert attachment.temp_path.ends_with?('rails.png')
    end

    def test_create_with_already_uploaded_data_and_new_uploaded_data_deletes_old_upload
      assert_file? @temp_file
      attachment = Attachment.new(:already_uploaded_data => @already_uploaded_path)
      attachment.uploaded_data = image_upload
      assert_not_file? @temp_file
      assert_not_directory? @temp_dir
    end

    def test_create_with_already_uploaded_data_checks_path_is_allowed
      assert_raises(InvalidAttachmentTempFileError) {Attachment.new(:already_uploaded_data => "some bad path")}
      assert_raises(InvalidAttachmentTempFileError) {Attachment.new(:already_uploaded_data => "/temp_dir/rails.png")}
      assert_raises(InvalidAttachmentTempFileError) {Attachment.new(:already_uploaded_data => "../../../temp_dir/rails.png")}
      assert_nothing_raised(InvalidAttachmentTempFileError) {Attachment.new(:already_uploaded_data => @already_uploaded_path)}
    end
    
    def test_save_fails_becuase_of_other_validation
      file_to_upload = text_upload
      @attachment = Attachment.new
      random_filename = "1234.5677.8899"
      @attachment.expects(:random_filename).returns(random_filename)
      @attachment.expects(:valid?).returns(false)
      @attachment.uploaded_data = file_to_upload
      assert_raises(ActiveRecord::RecordInvalid) { @attachment.save! }
      assert_equal "/1234.5677.8899/simple.txt", @attachment.already_uploaded_data
      expected_temp_file = File.join(PeelMeAGrape::IsAttachment.tempfile_path, @attachment.is_attachment_directory_name, random_filename, 'simple.txt' )
      previously = File.join(PeelMeAGrape::IsAttachment.tempfile_path, @attachment.is_attachment_directory_name, @attachment.already_uploaded_data)
      assert_equal expected_temp_file, previously
      assert_equal "text_upload file contents", File.read(previously)
    end

    def test_failing_update_with_valid_file_doesnt_change_existing_file
      @attachment.uploaded_data = text_upload
      @attachment.save!
      @attachment.reload
      @attachment.expects(:valid?).returns(false)
      @attachment.uploaded_data = fixture_file_string_io_upload('/files/simple2.txt', 'text/plain')
      assert_raise(ActiveRecord::RecordInvalid) do
        @attachment.save!
      end
      @attachment.reload
      assert_equal "text_upload file contents", File.read(@engine.full_filename(@attachment))
      assert_equal "simple.txt", @attachment.filename
    end

    def test_failing_update_without_file_doesnt_change_existing_file
      @attachment.uploaded_data = text_upload
      @attachment.save!
      @attachment.reload
      @attachment.expects(:valid?).returns(false)
      assert_raise(ActiveRecord::RecordInvalid) do
        @attachment.save!
      end
      @attachment.reload
      assert_equal "text_upload file contents", File.read(@engine.full_filename(@attachment))
      assert_equal "simple.txt", @attachment.filename
    end
  end
end