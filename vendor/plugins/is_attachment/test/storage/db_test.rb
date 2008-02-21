require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))

module PeelMeAGrape::IsAttachment::Storage
  class DbTest < Test::Unit::TestCase
    def setup
      @engine = Db.new(DbBackedAttachment)
      @attachment = DbBackedAttachment.new
      @attachment.is_attachment_storage_engine = @engine
      @saved_attachment= DbBackedAttachment.new
      @saved_attachment.uploaded_data = text_upload
      @saved_attachment.save!
    end

    def test_on_init_called_on_initialize
      Db.any_instance.expects(:on_init)
      Db.new(mock)
    end

    def test_included_checks_that_is_attachment_db_file_table_exists
      mock_connection = mock(:tables => ['my_attachment_table'])
      base = stub(:connection => mock_connection)
      assert_raises(IsAttachmentDbFileTableMissingError, "To use :db storage engine you must have an 'is_attachment_db_files' table. Use rake is_attachment:db_files_table_migration to create a migration.") do
        Db.new(base)
      end
    end

    def test_raises_if_columns_and_tables_not_there
      check_raises_for_missing_columns([])
      check_raises_for_missing_columns(['is_attachment_db_file_id'])
      check_raises_for_missing_columns(['content_type'])
    end

    def check_raises_for_missing_columns(columns)
      mock_connection = mock(:tables => ['is_attachment_db_files'])
      model = stub(:column_names => columns, :connection => mock_connection)
      assert_raises(PeelMeAGrape::IsAttachment::ConfigurationConflictError, "Using :db storage engine requires your model to have columns 'is_attachment_db_file_id' of type integer and content_type of type string.") do
        Db.new(model)
      end
    end

    def test_nothing_raise_when_required_tables_and_columns_present
      mock_connection = mock(:tables => ['is_attachment_db_files'])
      model = stub(:column_names => ['content_type', 'is_attachment_db_file_id'], :table_name => 'attachments', :connection => mock_connection, :belongs_to => true)
      assert_nothing_raised do
        Db.new(model)
      end
    end

    def test_respond_to_basic_interface
      assert @attachment.respond_to?(:persist_to_storage)
      assert @attachment.respond_to?(:remove_from_storage)
      assert @attachment.respond_to?(:public_path)
      assert @attachment.respond_to?(:copy_to_temp_file)
    end

    def test_is_attachment_db_file_model_defined
      assert Object.const_defined?(:IsAttachmentDbFile)
    end

    def test_persist_to_storage
      @attachment.uploaded_data = image_upload
      @engine.persist_to_storage(@attachment)
      assert_equal File.size(image_upload.path), @attachment.file_size
    end

    def test_sets_up_association
      assert @attachment.respond_to?(:is_attachment_db_file)
    end

    def test_public_path_raises_not_supported_exception
      assert_raises(PeelMeAGrape::IsAttachment::OperationNotSupportedError, "This attachment is backed by :db storage engine. The file doesn't have a path on disk - and you'll need to serve it using a controller.") do
        @attachment.public_path
      end
    end

    def test_save_attachment_creates_records
      attachment, db_file = assert_creates(:db_backed_attachment, :is_attachment_db_file) do
        DbBackedAttachment.create!(:uploaded_data => text_upload)
      end
      assert_equal db_file, attachment.is_attachment_db_file
    end

    def test_remove_from_storage
      assert_destroys(:is_attachment_db_file) do
        @saved_attachment.remove_from_storage
      end
    end

    def test_destroy
      assert_destroys(:db_backed_attachment, :is_attachment_db_file) do
        @saved_attachment.destroy
      end
    end

    def test_copy_to_temp_file
      temp_file = @saved_attachment.copy_to_temp_file
      assert temp_file.is_a?(Tempfile)
      expected_file_contents = "text_upload file contents"
      assert_equal expected_file_contents, File.read(temp_file.path)
    end
  end
end