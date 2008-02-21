module PeelMeAGrape::IsAttachment::Storage # :nodoc:
  class S3Config
    attr_accessor :access_key_id, :secret_access_key, :use_ssl, :bucket_name

    def initialize(options)
      options ||= {}
      options.assert_valid_keys(:access_key_id, :secret_access_key, :bucket_name, :use_ssl)
      raise ArgumentError.new("Invalid S3 Config - required keys are (:access_key_id, :secret_access_key and :bucket_name) - :use_ssl is optional. Check you have correctly configured /config/amazon_s3.yml for #{RAILS_ENV} environment") unless [:access_key_id, :secret_access_key, :bucket_name].detect{|required| !options.keys.include?(required)}.nil?
      self.access_key_id = options[:access_key_id].to_s
      self.secret_access_key = options[:secret_access_key].to_s
      self.bucket_name = options[:bucket_name].to_s
      self.use_ssl = options[:use_ssl]
    end

    def self.load(path)
      env_config = YAML.load_file(path)[RAILS_ENV] || {}
      self.new(env_config.symbolize_keys)
    end
  end

  class S3 < RemoteBase
    attr_accessor :config

    def on_init
      load_config
      establish_connection
    end

    def load_config
      self.config = S3Config.load(RAILS_ROOT + '/config/amazon_s3.yml')
    end

    def establish_connection
      AWS::S3::Base.establish_connection!({
          :access_key_id     => config.access_key_id,
          :secret_access_key => config.secret_access_key,
          :use_ssl           => config.use_ssl
        })
    end
    
    def persist_to_remote_storage(model_instance)
      AWS::S3::S3Object.store(attachment_path(model_instance), model_instance.temp_data, self.config.bucket_name,
        :content_type => model_instance.content_type,
        :access => :public_read
      )
    end

    def copy_to_temp_file(model_instance)
      if File.file?(file_system_engine.full_filename(model_instance))
        return file_system_engine.copy_to_temp_file(model_instance)
      else
        model_instance.set_random_temp_path
        File.open(model_instance.temp_path, "wb") { |f| f.write(file_data(model_instance)) }
        model_instance.file_size = File.size(model_instance.temp_path)
        File.new(model_instance.temp_path)
      end
    end

    # the path to the attachment file within your apps public directory
    def public_path(model_instance, version=nil)
      File.join("http://s3.amazonaws.com/", self.config.bucket_name, attachment_path(model_instance,version))
    end

    def file_data(model_instance)
      AWS::S3::S3Object.value(attachment_path(model_instance),self.config.bucket_name)
    end

    def remove_from_remote_storage(model_instance)
      AWS::S3::S3Object.delete(attachment_path(model_instance,model_instance.version_name), self.config.bucket_name)
    end
  end
end