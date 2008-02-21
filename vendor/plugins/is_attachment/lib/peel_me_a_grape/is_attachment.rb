module PeelMeAGrape # :nodoc:
  # == Example Usage
  # app/models/my_attachment.rb
  #     class MyAttachment < ActiveRecord::Base
  #       is_attachment :image_versions => {:thumb => "50x", :normal => {:cropper => [400,500]}}
  #     end
  #
  # app/views/my_attachments/new.html.erb
  #     <h1>New MyAttachment</h1>
  #     <%= error_messages_for 'my_attachment' %>
  #     <% form_for :my_attachment, @my_attachment, :url => my_attachments_url, :html => {:multipart => true } do |f| %>
  #       <%= f.is_attachment_file_field %>
  #       <%= f.submit "Save!", admin_portfolio_item_url(@portfolio_item) -%>
  #     <% end -%>
  #
  # app/controllers/my_attachments_controller.rb
  #     class MyAttachmentsController < ApplicationController
  #       def create
  #         @my_attachment = MyAttachment.new(params[:my_attachment])
  #         @my_attachment.save!
  #         redirect_to my_attachment_url(@my_attachment)
  #       rescue ActiveRecord::RecordInvalid
  #         render :action => 'new'
  #       end
  #     end
  #
  # By default MyAttachment will require an uploaded file to save. (See PeelMeAGrape::IsAttachment::Validation)
  #
  # == extending is_attachment
  # is_attachment provides 3 main extension points.
  # * <b>Storage Engines</b>
  #   Implement a subclass of PeelMeAGrape::IsAttachment::Storage::Base and register using PeelMeAGrape::IsAttachment.register_storage_engine
  # * <b>Image Engines</b>
  #   Implement a subclass of PeelMeAGrape::IsAttachment::Image::Base and register using PeelMeAGrape::IsAttachment.register_image_engine
  # * <b>Transformers</b>
  #   Implement a subclass of PeelMeAGrape::IsAttachment::Transformer::Base and register using PeelMeAGrape::IsAttachment.register_transformer
  module IsAttachment
    @@file_storage_base_path = File.join(RAILS_ROOT, 'public')
    @@image_content_types    = ['image/jpeg', 'image/pjpeg', 'image/gif', 'image/png', 'image/x-png']
    @@image_file_extensions  = ['jpeg', 'jpg', 'gif', 'png']
    @@tempfile_path          = File.join(RAILS_ROOT, 'tmp', 'is_attachment')
    @@custom_transformers    = {:cropper => PeelMeAGrape::IsAttachment::Transformer::Cropper,
                                :fixed_width => PeelMeAGrape::IsAttachment::Transformer::FixedWidth,
                                :fixed_height => PeelMeAGrape::IsAttachment::Transformer::FixedHeight }
    @@storage_engines        = {:file_system => PeelMeAGrape::IsAttachment::Storage::FileSystem, :db => PeelMeAGrape::IsAttachment::Storage::Db}
    @@image_engines          = {}
    @@builtin_image_engines  = [:rmagick, :mini_magick]

    @@builtin_image_engines.each do |engine|
      begin
        @@image_engines[engine] = eval("PeelMeAGrape::IsAttachment::Image::#{engine.to_s.classify}")
      rescue LoadError
        RAILS_DEFAULT_LOGGER.info("is_attachment: Unable to load #{engine} image engine. Check you have #{engine} gem installed.")
      end
    end

    @@default_validations = {:required => true}
    @@default_storage_engine = :file_system
    @@default_image_engine   = :mini_magick
    @@check_is_base_version_proc   = Proc.new { |model| model.base_version_id.nil? }

    mattr_reader :image_content_types, :image_file_extensions, :storage_engines, :image_engines, :custom_transformers, :check_is_base_version_proc
    mattr_accessor :file_storage_base_path, :tempfile_path, :default_storage_engine, :default_image_engine

    # Hash of all validations that will be applied to all is_attachment models. By default this is
    #   {:required => true}
    # If for example you want to limit the file_size of all attachments to 256KB you could do this in your /config/is_attachment/defaults.rb
    #    PeelMeAGrape::IsAttachment.default_validations[:max_file_size] = 256.kilobytes
    # You can still override defaults on a model by model basis
    #    class MyBigAttachment < ActiveRecord::Base
    #      is_attachment :validate => {:max_file_size => nil, :required => false}
    #    end
    def self.default_validations
      @@default_validations
    end

    # You can set what storage engine to use for all is_attachment models. (:file_system by default)
    #    PeelMeAGrape::IsAttachment.default_storage_engine = :s3
    # You can still override the storage engine on a model by model basis
    #    class MyDBAttachment < ActiveRecord::Base
    #      is_attachment :storage_engine => :db
    #    end
    def self.default_storage_engine=(engine)
      raise UnregisteredExtensionError.new("No Storage Engine Registered for #{engine}") unless @@storage_engines.keys.include?(engine)
      @@default_storage_engine = engine
    end

    # You can set what image engine to use for all is_attachment models. (:rmagick by default)
    #    PeelMeAGrape::IsAttachment.default_image_engine = :mini_magick
    # You can still override the image engine on a model by model basis
    #    class MyMiniMagickAttachment < ActiveRecord::Base
    #      is_attachment :image_engine => :rmagick
    #    end
    def self.default_image_engine=(engine)
      unless @@image_engines.keys.include?(engine)
        raise MissingDependancyError.new("It seems a dependancy is missing for image engine - #{engine}. Try 'sudo gem install #{engine}'") if @@builtin_image_engines.include?(engine) 
        raise UnregisteredExtensionError.new("No Image Engine Registered for #{engine}")
      end
      @@default_image_engine = engine
    end

    # You can register your own storage engines.
    # Raises <tt>BadExtensionClassError</tt> if engine doesn't respond to required methods.
    def self.register_storage_engine(key, engine)
      require_ancestor_of(Storage::Base, engine)
      @@storage_engines[key] = engine
    end

    # You can register your own image engines.
    # Raises <tt>BadExtensionClassError</tt> if engine doesn't respond to required methods.
    def self.register_image_engine(engine)
      require_ancestor_of(Image::Base, engine)
      @@image_engines[engine.name] = engine
    end

    # You can register your own Transformers.
    # Raises <tt>BadExtensionClassError</tt> if transformer_class isn't a PeelMeAGrape::IsAttachment::Transformer::Base
    def self.register_transformer(key, transformer_class)
      require_ancestor_of(Transformer::Base, transformer_class)
      @@custom_transformers[key] = transformer_class
    end

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

    module ActMethods
      # Options:
      # *  <tt>:validate</tt> - (optional) hash to configure validations ( content_type, file_size, image width and height, and whether an attachment is required )
      # *  <tt>:image_versions</tt> - (optional) configure to create one or more versions of the base_version
      # *  <tt>:storage_engine</tt> - (optional) storage engine to use - defaults to :file_system
      # *  <tt>:image_engine</tt> - (optional) image engine to use - defaults to :rmagick
      # *  <tt>:backgroundrb</tt> - (optional) process images using backgroundrb. defaults to false
      #
      # Examples:
      #   is_attachment
      #   is_attachment :image_version => { :thumb => 50, :medium => "400x300" }
      #   is_attachment :image_version => { :thumb => 50, :medium => "400x300" }, :image_engine => :mini_magick, :storage_engine => :db
      #
      # === Validations
      # The :validate option takes a hash. The allowed keys are:
      # *  <tt>:required</tt> - defaults to true
      # *  <tt>:width</tt> - either a Fixnum or a Range.
      # *  <tt>:height</tt> - either a Fixnum or a Range
      # *  <tt>:content_type</tt> - takes either a single string or an array of strings of valid content_types for the attachment. The symbol :image is expanded out to cover most common image file formats.
      # *  <tt>:file_size</tt> - either a Fixnum or a Range
      # *  <tt>:min_width</tt> - Fixnum
      # *  <tt>:min_height</tt> - Fixnum
      # *  <tt>:max_width</tt> - Fixnum
      # *  <tt>:max_height</tt> - Fixnum
      # *  <tt>:max_file_size</tt> - Fixnum
      #
      # ==== Validations Examples
      #   is_attachment :validate => { :width => (600..1200), :height => 500, :max_file_size => 1.megabyte }
      #   is_attachment :validate => { :content_type => [:image, 'text/plain'] }
      #   is_attachment :validate => { :required => false }
      #
      # === Image Versions
      # The :image_versions option takes a hash. Each entry in the hash represents a version of the original image (if an image is attached) that will be generated.
      # The hash entry key will be used as the version_name of the generated version and the hash entry value is used to configure how that version is generated.
      # The are many different ways to configure the version generation:
      # ===== Fixnum
      #   is_attachment :image_versions => {:thumb => 50}
      # will generate a thumb from the base_version 50x50 pixels. doesn't necessarily maintain aspect ratios.
      #
      # ===== Fixnum
      #   is_attachment :image_versions => {:thumb => [50, 80] }
      # will generate a thumb from the base_version 50x80 pixels. doesn't necessarily maintain aspect ratios.
      #
      # ===== String
      #   is_attachment :image_versions => {:thumb => "50x"}
      # will generate a thumb from the base_version 50 pixels wide - the height will be adjusted to maintain the original aspect ratio. This String is interpreted as a ImageMagick geometry string (see http://www.simplesystems.org/RMagick/doc/imusage.html#geometry)
      #
      # ===== Symbol
      #   is_attachment :image_versions => {:thumb => :custom}
      #   def custom(img)
      #     img.thumbnail!(50).border!(2,2,red)
      #   end
      # will generate call a method and pass it an image which to process. (eg if rmagick engine configured then img will be a Magick::Image). is_attachment handles everything else like persisting the end result to disk - all you have to do in the custom method is process the img and return it.
      #
      # ===== Hash
      #   is_attachment :image_versions => {:cropped_thumb => { :cropper => [50, 80] }}
      # process with a PeelMeAGrape::IsAttachment::Transformer::Base registered as :cropper. In this case it configures a PeelMeAGrape::IsAttachment::Transformer::Cropper
      def is_attachment(options = {})
        FailEarlyOptionsChecker.check(self, options)

        define_associations unless options[:image_versions].blank?

        unless included_modules.include? InstanceMethods
          class_inheritable_accessor :image_version_options, :validate_options
          class_inheritable_accessor :is_attachment_storage_engine, :is_attachment_image_engine

          attr_accessor :temp_path, :upload_to_process, :reusing_existing_upload

          attr_protected :filename

          include InstanceMethods
          include Backgroundrb if options[:backgroundrb].eql?(true)
          include Validation

          include AttachmentMetaDataAccessors
          include StorageEngineProxies
          include ImageEngineProxies
          include FileHelper

          extend ClassMethods

          storage_engine_name = options[:storage_engine] || PeelMeAGrape::IsAttachment.default_storage_engine
          self.is_attachment_storage_engine = PeelMeAGrape::IsAttachment.storage_engines[storage_engine_name].new(self)

          image_engine_name = options[:image_engine] || PeelMeAGrape::IsAttachment.default_image_engine
          self.is_attachment_image_engine = PeelMeAGrape::IsAttachment.image_engines[image_engine_name].new(self)

          after_save :process_base_version
          before_save :process_from_base_version
          after_destroy :remove_from_storage
          setup_validations
        end

        self.validate_options = options[:validate] || {}
        self.validate_options.reverse_merge! PeelMeAGrape::IsAttachment.default_validations
        self.image_version_options = configure_image_custom_transformers(options)
      end

      # If you have extra columns on your attachment model that you want to validate against - chances are you only want to validate them on the base version.
      #   with_base_version_validations do |base_versions|
      #     base_versions.validates_presence_of :title, :description
      #     base_versions.validates_uniqueness_of :title, :scope => :portfolio_item_id
      #   end
      def with_base_version_validations(&block)
        with_options(:if => PeelMeAGrape::IsAttachment.check_is_base_version_proc ) do |base|
          block.call(base) unless block.nil?
        end
      end

      protected
      # registers attachment validations on attachment base version
      def setup_validations
        validate do |attachment|
          attachment.validate_attachment if attachment.is_base_version?
        end
      end

      # adds has_many :versions and belongs_to :base_version associations
      def define_associations
        with_options :foreign_key => 'base_version_id' do |m|
          m.has_many  :versions, :class_name => base_class.to_s, :dependent => :destroy do
            # Defined on the has_many :versions collection proxy - finds version with <em>version name</em>
            def [](version_name)
              self.find_by_version_name(version_name.to_s)
            end
          end
          m.belongs_to :base_version, :class_name => base_class.to_s
        end
      end

      # Instantiates custom transformers in :image_versions option hash. Returns the :image_versions hash with custom transformers configured.
      # eg. with the following configuration
      #    is_attachment :image_versions => { :cropped_thumb => { :cropper => 50 } }
      # this method will configure an instance of the PeelMeAGrape::IsAttachment::Transformer::Cropper with a size of 50
      def configure_image_custom_transformers(options)
        image_version_options = options[:image_versions] || {}
        hash_options = image_version_options.select{|k, v| v.is_a? Hash}
        hash_options.each do |key, value|
          transformer_name = value.keys[0]
          transformer = PeelMeAGrape::IsAttachment.custom_transformers[transformer_name].new(value[transformer_name])
          include transformer.module_to_include unless included_modules.include? transformer.module_to_include
          image_version_options[key] = transformer
        end
        image_version_options
      end
    end

    module ClassMethods
      # Reprocess all attachments. Useful when you change the :image_versions configuration on your model and want existing attachments to match the new config.
      #   MyAttachment.reprocess_all_attachments
      def reprocess_all_attachments
        if column_names.include?('base_version_id')
          self.find(:all, :conditions => {:base_version_id => nil}).each do |attachment_record|
            attachment_record.reprocess_attachment
          end
        end
      end

      # name of directory/path under which uploaded files will be available. (same as table name)
      #   MyAttachment < ActiveRecord::Base
      #   MyAttachment.is_attachment_directory_name => 'my_attachments'
      #
      #   MySpecialAttachment < MyAttachment
      #   MySpecialAttachment.is_attachment_directory_name => 'my_attachments'
      def is_attachment_directory_name
        base_class.to_s.underscore.pluralize
      end

      # directory where files will be temporarily stored during uploading
      def temp_file_base_directory
        File.join(PeelMeAGrape::IsAttachment.tempfile_path, self.is_attachment_directory_name)
      end
    end

    module InstanceMethods
      # See ClassMethods#temp_file_base_directory
      def temp_file_base_directory
        self.class.temp_file_base_directory
      end

      # See ClassMethods#is_attachment_directory_name
      def is_attachment_directory_name
        self.class.is_attachment_directory_name
      end

      # returns true if a file has successfully been attached to this record.
      def has_attachment?
        !self.filename.blank?
      end

      # returns true if the number of version is equal to the number of configured versions to generate.
      def has_all_versions?
        !is_base_version? || (self.versions.size == self.class.image_version_options.size)
      end

      # true if content_type is one of PeelMeAGrape::IsAttachment.image_content_type. When content_type is not present/set will check if the filename extension is one of PeelMeAGrape::IsAttachment.image_file_extensions
      def image?
        content_type.blank? ?
          PeelMeAGrape::IsAttachment.image_file_extensions.include?(filename_extension) :
          PeelMeAGrape::IsAttachment.image_content_types.include?(content_type)
      end

      # true unless base_version_id is set
      def is_base_version?
        !self.respond_to?(:base_version_id) || self.base_version_id.nil?
      end

      # true if the model has #uploaded_data= assigned.
      def upload_to_process?
        self.upload_to_process
      end

      # true when #upload_to_process? but not reusing_existing_upload?
      def new_upload_to_process?
        upload_to_process? and not reusing_existing_upload?
      end

      # true when we have successfully assigned to #already_uploaded_data=
      def reusing_existing_upload?
        self.reusing_existing_upload
      end

      # returns nil - in case used in a form.
      def uploaded_data()
        nil;
      end

      # assign file data to this to create your attachment.
      #
      #   <% form_for :my_attachment, :html => { :multipart => true } do |f| -%>
      #     <%= f.file_field :uploaded_data %>
      #     <%= submit_tag 'Upload' %>
      #   <% end -%>
      #
      # or better yet
      #
      #   <% form_for :my_attachment, :html => { :multipart => true } do |f| -%>
      #     <%= f.is_attachment_file_field %>
      #     <%= submit_tag 'Upload' %>
      #   <% end -%>
      #
      #   @my_attachment = MyAttachment.create! params[:my_attachment]
      def uploaded_data=(file_data)
        return nil if file_data.nil? || file_data.size == 0
        raise TypeError.new(":uploaded_data should be assigned a file - you passed a String. Check if the form's encoding has been set to 'multipart/form-data'.") if file_data.is_a?(String)
        clear_existing_temp_file
        self.upload_to_process = true
        self.content_type = file_data.content_type.to_s.strip
        self.filename     = file_data.original_filename
        if file_data.is_a?(StringIO)
          file_data.rewind
          copy_uploaded_file_to_temp_path(file_data)
        else
          file_data.close
          copy_uploaded_file_to_temp_path(file_data)
        end
        set_width_and_height_from_image if self.needs_width_or_height_before_validation?
      end

      def clear_existing_temp_file
        unless self.temp_path.nil?
          FileUtils.rm_rf(File.dirname(self.temp_path))
          self.temp_path = nil
        end
      end

      # Copies uploaded file to a temp file within PeelMeAGrape::IsAttachment.tempfile_path
      def copy_uploaded_file_to_temp_path(file)
        set_random_temp_path
        if file.respond_to?(:path) && file.path && File.exists?(file.path)
          FileUtils.copy_file(file.path, self.temp_path)
        elsif file.respond_to?(:read)
          File.open(self.temp_path, "wb") { |f| f.write(file.read) }
        else
          raise ArgumentError.new("Do not know how to handle #{file.inspect}")
        end
        self.file_size = File.size(temp_path)
      end

      # sets temp_path to a new random name of the form /tmp/is_attachments/#{table_name}/#{filename}
      def set_random_temp_path
        attachment_temp_dir = File.join(self.temp_file_base_directory, random_filename)
        FileUtils.mkdir_p(attachment_temp_dir)
        self.temp_path = File.join(attachment_temp_dir, self.filename)
      end

      # path to #temp_path relative to #temp_file_base_directory - used to keep uploaded files files across form redisplays
      def already_uploaded_data
        self.temp_path.nil? ? nil : relative_path(self.class.temp_file_base_directory, self.temp_path)
      end

      # Used to keep uploaded files files across form redisplays - if assigned with a valid path (of form #already_uploaded_data) - will use the corresponding file (previously uploaded) as if it was passed to #uploaded_data=
      def already_uploaded_data=(path)
        return if path.blank?
        path_on_disk = File.expand_path(File.join(self.class.temp_file_base_directory, path))
        raise InvalidAttachmentTempFileError.new("Invalid Format of 'already_uploaded_data'") unless path_on_disk.starts_with?(File.expand_path(self.class.temp_file_base_directory))
        raise InvalidAttachmentTempFileError.new("Uploaded Temp File Doesn't Exist") unless File.file?(path_on_disk)
        if self.temp_path.blank?
          self.upload_to_process = true
          self.reusing_existing_upload = true
          self.temp_path = path_on_disk
        end
      end

      # reads the contents of the attachment temp_file
      def temp_data
        f = File.new(temp_path, 'rb')
        begin
          f.read
        ensure
          f.close
        end
      end

      # sanitizes your attachment filename before writing the attribute
      def filename=(new_name)
        write_attribute :filename, sanitize_filename(new_name)
      end

      # generated versions get filenames derived from their base_version. A base_version with filename of "my_image.jpg" will generate a filename of "my_image_thumb.jpg" for a #version_name of 'thumb'
      def file_name_for_version(version=nil)
        return filename if version.blank?
        ext = nil
        basename = filename.gsub(/\.\w+$/) {|s| ext = s; ''}
        "#{basename}_#{version}#{ext}"
      end

      # If the target object #is_base_version? then this will persist the file to storage (if file attached), and create records
      # for all the image_versions configured (If they already exist they will be resaved with the new - possibly changed - filename of the baseversion, and will in turn reprocess themselves)
      def process_base_version
        if is_base_version?
          persist_to_storage_if_new_file_attached
          if upload_to_process? && image?
            update_width_and_height_from_image unless self.needs_width_or_height_before_validation?
            image_version_options.each do |version_name, process|
              version = self.class.find_or_initialize_by_base_version_id_and_version_name(self.id, version_name.to_s)
              version.filename = file_name_for_version(version_name)
              begin
              version.save!
              rescue ActiveRecord::RecordInvalid
                raise "BLAH"
              end
            end
          end
        end
      end

      # If the target object is not base_version then this will create and persist a transformed version of the base_version image attachment. (#transform_base_version_image) and persist it to storage (#persist_to_storage_if_new_file_attached)
      def process_from_base_version
        unless is_base_version?
          transform_base_version_image
          persist_to_storage_if_new_file_attached
        end
      end

      # uses with_image_then_inspect and calls #transform_image with the yielded image object
      def transform_base_version_image
        self.temp_path = base_version.copy_to_temp_file.path
        transform_image_at_temp_path
      end

      # reprocesses the files associated with this attachment. Calling it on a base_version will cause all it's versions to be reprocessed.
      def reprocess_attachment
        is_base_version? ? reprocess_base_version : process_from_base_version
      end

      # will cause all :image_versions to be recreated.
      def reprocess_base_version
        self.temp_path = self.copy_to_temp_file.path
        self.upload_to_process = true
        process_base_version
      end

      # returns image_version configuration for a version.
      #
      # so for a record with <tt>version_name</tt> of "thumb" and the following configuration
      #   is_attachment :image_versions => {:thumb => [200,300]}
      # we return <tt>[200,300]</tt>
      def image_version_option
        image_version_options[version_name.to_sym] unless version_name.nil?
      end

      # returns a string representing the size of this image. eg if width is 50 and height is 60 #image_size returns '50x60'
      def image_size
        (!width.nil? && !height.nil? && width > 0 && height > 0) ? [width.to_s, height.to_s] * 'x' : nil
      end

      # Returns true if any validations deal with width or height - used to try and avoid reading the image file if it doesn't need to be.
      def needs_width_or_height_before_validation?
        ! self.validate_options.map(&:to_s).detect {|v| v.index("width") || v.index("height") }.nil?
      end

      # If attachment is an image - will update width/height/aspect_ratio values by getting width and height using the image engine.
      def update_width_and_height_from_image
        columns_to_update = [:width, :height, :aspect_ratio].find_all{|col| self.class.column_names.include?(col.to_s)}
        unless columns_to_update.empty?
          set_width_and_height_from_image
          values_to_update = columns_to_update.map{|col| self.send(col) }
          conditions = columns_to_update.map{|col| "#{col.to_s} = ?"}.join(", ")
          self.class.update_all(([conditions] +  values_to_update), ['id = ?', id])
        end
      end
      # if our attachment is an image set it's width and heigh attributes from the image object
      # #NOTE: this mechanism needs reworking - only time we need it before saving record is if we validate against width or height. This method has the overhead of hitting our image_engine in our rails processing loop - even if using background rb.
      def set_width_and_height_from_image
        if image?
          with_image do |img|
            grab_dimensions_from_image(img)
          end
        end
      end
      protected
      # calls #persist_to_storage if we have a file to save....
      def persist_to_storage_if_new_file_attached
        persist_to_storage unless temp_path.nil?
      end


    end

    # Accessors for :width, :height, :file_size and :content_type - when the columns are not present the values will ve stored in instance variables to still allow validation.
    module AttachmentMetaDataAccessors
      def file_size=(value)
        self.class.column_names.include?('file_size') ? write_attribute(:file_size, value) : @file_size = value.to_i
      end
      def file_size
        read_attribute(:file_size) || @file_size
      end
      def width=(value)
        self.class.column_names.include?('width') ? write_attribute(:width, value) : @width = value.to_i
      end
      def width
        read_attribute(:width) || @width
      end
      def height=(value)
        self.class.column_names.include?('height') ? write_attribute(:height, value) : @height = value.to_i
      end
      def height
        read_attribute(:height) || @height
      end
      def content_type=(content_type)
        self.class.column_names.include?('content_type') ? write_attribute(:content_type, content_type) : @content_type = content_type
      end
      def content_type
        read_attribute(:content_type) || @content_type
      end
    end

    # Methods added to your is_attachment model that proxy to the configured image engine.
    # Calls are delegated to some subclass of some sublcass of PeelMeAGrape::IsAttachment::Image::Base
    module ImageEngineProxies
      def with_image(&block)
        is_attachment_image_engine.with_image(self, &block)
      end
      def with_image_then_inspect(&block)
        is_attachment_image_engine.with_image_then_inspect(self, &block)
      end
      def grab_dimensions_from_image(img)
        is_attachment_image_engine.grab_dimensions_from_image(self, img)
      end
      def transform_image_at_temp_path
        is_attachment_image_engine.transform_image_at_temp_path(self)
      end
    end

    # Methods added to your is_attachment model that proxy to the configured storage engine.
    # Calls are delegated to some subclass of some sublcass of PeelMeAGrape::IsAttachment::Storage::Base
    module StorageEngineProxies
      def persist_to_storage
        is_attachment_storage_engine.persist_to_storage(self)
      end
      def remove_from_storage
        is_attachment_storage_engine.remove_from_storage(self)
      end
      def public_path(version=nil)
        is_attachment_storage_engine.public_path(self, version)
      end
      def copy_to_temp_file
        is_attachment_storage_engine.copy_to_temp_file(self)
      end
      # returns true if storage engine is_a? PeelMeAGrape::IsAttachment::Storage::RemoteBase
      def persists_remotely?
        is_attachment_storage_engine.is_a?(PeelMeAGrape::IsAttachment::Storage::RemoteBase)
      end
    end

    private
    def self.require_ancestor_of(ancestor, decendant)
      raise ArgumentError.new("expected to be a Class - not an instance of one") unless decendant.respond_to?(:ancestors)
      raise BadExtensionClassError.new("Expected Class of type #{ancestor.to_s}") unless decendant.ancestors.include?(ancestor)
    end
  end
end

begin
  require 'aws/s3'
  PeelMeAGrape::IsAttachment.register_storage_engine(:s3, PeelMeAGrape::IsAttachment::Storage::S3)
rescue LoadError
end