module PeelMeAGrape::IsAttachment::Storage
  class IsAttachmentDbFileTableMissingError < StandardError # :nodoc:
  end
  # Base class for IsAttachment Storage Engines.
  # Storage Engines determine how/where uploaded files are stored (Eg local file system, database, remote web service etc...)
  class Base
    include PeelMeAGrape::IsAttachment::FileHelper
    attr_accessor :attachment_class

    # Passed the <tt>attachment_class</tt> it will work against.
    def initialize(attachment_class)
      self.attachment_class = attachment_class
      on_init
    end

    # called by default #initialize - to allow you to inspect or extend your attachment model for use with your particular Storage Engine.
    # eg.
    #   def on_init
    #     raise unless attachment_class.columns.include?('some_required_column')
    #   end
    def on_init
    end

    # Should copy the file attached to <tt>model_instance</tt> to a TempFile
    def copy_to_temp_file(model_instance)
      raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("Abstract Method - please override.")
    end

    # Path attachment is available to public at
    # eg.
    #    @attachment.public_path => '/attachmenst/1/my_first_upload.jpg'  (relative to my_app/public)
    #    @attachment.public_path => 'http://some.webservice.com/my_app/attachmenst/1/my_first_upload.jpg'
    def public_path(model_instance, version_name = nil)
      raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("Abstract Method - please override.")
    end

    # Should save the file attached to model_instance for later retrieval
    def persist_to_storage(model_instance)
      raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("Abstract Method - please override.")
    end

    # Should permanently remove the file attached to model_instance
    def remove_from_storage(model_instance)
      raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("Abstract Method - please override.")
    end

    # the directory on disk than this attachments files are stored in. generated versions are stored in a directory named after the id of the base_version
    def attachment_dir(model_instance)
      File.join(model_instance.is_attachment_directory_name, attachment_dir_id(model_instance).to_s)
    end

    # returns the id used to name the #attachment_dir. If your attachment is a base_version then it uses it's id - otherwise it will use it's base_versions id
    def attachment_dir_id(model_instance)
      model_instance.respond_to?(:base_version_id) ? model_instance.base_version_id || model_instance.id : model_instance.id
    end

    # path string used to identify the attachment - relative to storage base.
    # eg my_attachments/13/hello.jpg
    def attachment_path(model_instance, version=nil)
      File.join(attachment_dir(model_instance), model_instance.file_name_for_version(version))
    end
  end
end