module PeelMeAGrape::IsAttachment
  module Storage # :nodoc:
    # You can configure the base path for your file system stored attachments.
    #    PeelMeAGrape::IsAttachment.file_storage_base_path = File.join(RAILS_ROOT,'public','i')
    # will give you urls like http://my_app.com/i/my_attachment/1/image.jpg
    class FileSystem < Base
      # Copies the attachment file to permanent storage.
      def persist_to_storage(model_instance)
        file_name = full_filename(model_instance)
        FileUtils.mkdir_p(File.dirname(file_name))
        FileUtils.cp(model_instance.temp_path, file_name)
        File.chmod(0644, file_name)
      end

      # Deletes the attachment file from permanent sotrage. 
      def remove_from_storage(model_instance)
        file = full_filename(model_instance)
        dir = File.dirname(file)
        FileUtils.rm file
        Dir.rmdir(dir) if Dir.empty?(dir)
      rescue
        RAILS_DEFAULT_LOGGER.info "Exception destroying  #{full_filename(model_instance).inspect}: [#{$!.class.name}] #{$1.to_s}"
        RAILS_DEFAULT_LOGGER.warn $!.backtrace.collect { |b| " > #{b}" }.join("\n")
      end

      # the path to the attachment file within your apps public directory
      def public_path(model_instance, version=nil)
        relative_path(File.join(RAILS_ROOT, 'public'), full_filename(model_instance,version)) 
      end

      # returns a Tempfile with the attachments file data as its contents.
      def copy_to_temp_file(model_instance)
        with_temp_file do |tmp|
          tmp.close
          FileUtils.cp full_filename(model_instance), tmp.path
        end
      end

      # full path to attachment file on disk
      def full_filename(model_instance, version=nil)
        File.join(PeelMeAGrape::IsAttachment.file_storage_base_path, attachment_path(model_instance, version))
      end
    end
  end
end