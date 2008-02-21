module PeelMeAGrape::IsAttachment
  module Storage # :nodoc:
    # Persists attached files to table called <tt>is_attachment_db_files</tt>. There is a rake task provided to create a migration to create this table
    #    rake is_attachment:db_files_table_migration
    # ==== Required Columns
    # * is_attachment_db_file_id (integer)
    # * content_type (string)
    class Db < Base
      include PeelMeAGrape::IsAttachment::FileHelper
      # when included makes sure your model has the required columns - 'is_attachment_db_file_id' and 'content_type'
      #
      # sets up a belongs to association on your attachment model equivalent to
      #    belongs_to :is_attachment_db_file
      def on_init()
        raise PeelMeAGrape::IsAttachment::Storage::IsAttachmentDbFileTableMissingError.new("To use :db storage engine you must have an 'is_attachment_db_files' table. Use rake is_attachment:db_files_table_migration to create a migration.") unless attachment_class.connection.tables.include?('is_attachment_db_files')
        raise PeelMeAGrape::IsAttachment::ConfigurationConflictError.new("Using :db storage engine requires your model to have columns 'is_attachment_db_file_id' of type integer and content_type of type string.") unless attachment_class.column_names.include?('is_attachment_db_file_id') && attachment_class.column_names.include?('content_type')
        Object.const_set(:IsAttachmentDbFile, Class.new(ActiveRecord::Base)) unless Object.const_defined?(:IsAttachmentDbFile)
        attachment_class.belongs_to :is_attachment_db_file, :class_name => '::IsAttachmentDbFile', :foreign_key => 'is_attachment_db_file_id'
      end

      # writes attachment data to db_file - and sets 'is_attachment_db_file_id' appropriately on attachment model
      def persist_to_storage(model_instance)
        db_file = model_instance.is_attachment_db_file || IsAttachmentDbFile.new
        db_file.data = model_instance.temp_data
        db_file.save!
        model_instance.is_attachment_db_file_id = db_file.id
        model_instance.is_attachment_db_file = db_file
        model_instance.class.update_all ['is_attachment_db_file_id = ?', model_instance.is_attachment_db_file_id], ['id = ?', model_instance.id]
      end

      # destroys attachment db file record
      def remove_from_storage(model_instance)
        model_instance.is_attachment_db_file.destroy unless model_instance.is_attachment_db_file.nil?
      end

      # public_path is not a supported operation and will raise an Error
      def public_path(*args)
        raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("This attachment is backed by :db storage engine. The file doesn't have a path on disk - and you'll need to serve it using a controller.")
      end

      # returns a Tempfile with the attachments db file data as its contents.
      def copy_to_temp_file(model_instance)
        write_to_temp_file(model_instance.is_attachment_db_file.data)
      end
    end
  end
end