module PeelMeAGrape # :nodoc:
  module IsAttachment
    class AttachmentColumnsError < StandardError # :nodoc:
    end
    class ConfigurationConflictError < StandardError # :nodoc:
    end
    class BadExtensionClassError < StandardError # :nodoc:
    end
    class MissingDependancyError < StandardError # :nodoc:
    end
    class UnregisteredExtensionError < StandardError # :nodoc:
    end
    class BadAttachmentProcessorError < StandardError # :nodoc:
    end
    class OperationNotSupportedError < StandardError # :nodoc:
    end
    class InvalidAttachmentTempFileError < StandardError # :nodoc:
    end
  end
end