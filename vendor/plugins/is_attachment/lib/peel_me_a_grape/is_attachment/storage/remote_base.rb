module PeelMeAGrape::IsAttachment::Storage
  # Base class for IsAttachment Storage Engines.
  # Storage Engines determine how/where uploaded files are stored (Eg local file system, database, remote web service etc...)
  class RemoteBase < Base
    class_inheritable_accessor :file_system_engine

    def initialize(attachment_class)
      super(attachment_class)
      self.file_system_engine = FileSystem.new(attachment_class)
    end

    def persist_to_storage(model_instance)
      self.file_system_engine.persist_to_storage(model_instance)
      persist_to_remote_storage(model_instance)
    end

    def persist_to_remote_storage(model_instance)
      raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("Abstract Method - please override.")
    end
    
    def remove_from_storage(model_instance)
      remove_from_remote_storage(model_instance)
      self.file_system_engine.remove_from_storage(model_instance)
    end
    
    def remove_from_remote_storage(model_instance)
      raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("Abstract Method - please override.")
    end
  end
end