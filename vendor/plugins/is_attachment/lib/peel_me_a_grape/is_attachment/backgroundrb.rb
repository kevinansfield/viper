module PeelMeAGrape::IsAttachment
  # Integrates backgroundDRb rails plugin (http://backgroundrb.rubyforge.org/) with is_attachment to cut out long running processes in rails request invocation loop.
  # Configure your model to process it's versions in backgroundDRb job by setting :backgroundrb option to true.
  #    is_attachment :image_versions => {:thumb => 50}, :backgroundrb => true
  module Backgroundrb
    # Checks the model has the column 'backgroundrb_job_key' which is required when using backgroundrb
    # Method chains in the behaviour to process with backgroundrb.
    def self.included(base)
      raise ConfigurationConflictError.new("backgroundrb not installed") unless Object.const_defined?(:MiddleMan)
      raise ConfigurationConflictError.new("To use backgroundrb your model must include a 'backgroundrb_job_key' column.") unless base.column_names.include?('backgroundrb_job_key')
      base.alias_method_chain :process_base_version, :backgroundrb
      base.alias_method_chain :reprocess_attachment, :backgroundrb
    end

    # Instead of going ahead and processing the image when we save our record - we create a backgroundrb worker to do it - and set the job key on the record being processed.
    # Creates backgroundrb job - if has image_versions or is persisted remotely
    def process_base_version_with_backgroundrb # todo should only get called if there is an upload to process... only if temp path not nil??
      if !running_in_backgrounrb?
        if ( is_base_version? && !image_version_options.empty? ) || persisted_remotely?
          update_backgroundrb_job_key(MiddleMan.new_worker(:class => :is_attachment_process_base_worker, :args => {:id => self.id, :class => self.class.to_s, :temp_path => self.temp_path}))
        end
      else
        process_base_version_without_backgroundrb
      end
    rescue StandardError => e
      log_error_creating_worker
      process_base_version_without_backgroundrb
    end

    # Creates a backgroundrb worker to reprocess our attachment
    def reprocess_attachment_with_backgroundrb
      if !running_in_backgrounrb?
        update_backgroundrb_job_key(MiddleMan.new_worker(:class => :is_attachment_reprocess_worker, :args => {:id => self.id, :class => self.class.to_s}))
      else
        reprocess_attachment_without_backgroundrb
      end
    rescue
      log_error_creating_worker
      reprocess_attachment_without_backgroundrb
    end

    # updates this reocrds backgroundrb_job_key with <tt><key/tt>
    def update_backgroundrb_job_key(key)
      self.class.update_all ['backgroundrb_job_key = ?', key], ['id = ?', self.id]
    end

    # true when all versions are created and the job key is set to nil.
    def backgroundrb_finished?
      !running_in_backgrounrb? && has_all_versions?
    end

    def running_in_backgrounrb?
      !self.backgroundrb_job_key.nil?
    end

    protected
    # If there is a problem creating the backgroundrb worker - eg drb server not started, then we log an error (an fallback to processing the attachment in process)
    def log_error_creating_worker
      message = "Problem Creating BackgroundRb Worker - Resorting to processing in process."
      RAILS_DEFAULT_LOGGER.error(message)
    end
  end
end