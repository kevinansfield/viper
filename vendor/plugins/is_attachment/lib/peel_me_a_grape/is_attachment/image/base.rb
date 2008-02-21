module PeelMeAGrape::IsAttachment::Image
  # Base class for IsAttachment Image Engines.
  # Image Engines are used to create image_versions (thumbnails etc) of uploaded images.
  class Base
    include PeelMeAGrape::IsAttachment::FileHelper
    attr_accessor :attachment_class

    # Passed the <tt>attachment_class</tt> it will work against.
    def initialize(attachment_class)
      self.attachment_class = attachment_class
      on_init
    end

    # called by default #initialize - to allow you to inspect or extend your attachment model for use with your particular Image Engine.
    # eg.
    #   def on_init
    #     raise unless attachment_class.columns.include?('some_required_column')
    #   end
    def on_init
    end

    # Should return a sensible :symbol to identify your image engine - eg PeelMeAGrape::IsAttachment::Image::Rmagick uses :rmagick
    def self.name
      raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("Abstract Method - please override. Expects symbol to identify engine by.")
    end

    # Entry point for is_attachment calling Image Engine to process an attachment.
    def transform_image_at_temp_path(model_instance)
      with_image_then_inspect(model_instance) {|img| transform_image(model_instance, img) }
    end

    # calls the appropriate transform method depending on the image_version configuration.
    #    is_attachment :image_versions => { :string_version => "50x", :fixnum_version => 50, :array_version => [50,60], :symbol_version => :custom_method, :hash_version => { :cropper => [50,60] } }
    #
    # * <tt>:string_version</tt> will call transform_image_with_geometry_string
    # * <tt>:fixnum_version</tt> and <tt>:array_version</tt> will call transform_image_with_array
    # * <tt>:symbol_version</tt> will call transform_image_with_custom_method
    # * <tt>:hash_version</tt> will call transform_image_with_custom_transformer
    def transform_image(model_instance, img)
      option = model_instance.image_version_option
      unless option.nil?
        if option.is_a?(Symbol)
          img = transform_image_with_symbol(model_instance, img, option)
        elsif option.is_a?(String)
          img = transform_image_with_geometry_string(img, option)
        elsif option.is_a?(Fixnum) || (option.is_a?(Array) && option.first.is_a?(Fixnum))
          option = [option, option] if option.is_a?(Fixnum)
          img = transform_image_with_array(model_instance, img, option)
        elsif option.is_a? PeelMeAGrape::IsAttachment::Transformer::Base
          img = transform_image_with_custom_transformer(model_instance, img, option)
        end
      end
      img
    end

    # calls a method on the transformer named depending on the image engine configured. With the default image_engine, :rmagick, we call 'transform_with_rmagick' on the transformer, passing it our image object.
    def transform_image_with_custom_transformer(model_instance, img, transformer)
      method = "transform_with_" + self.class.name.to_s
      transformer.send(method, self, img, model_instance)
    end

    # calls #transform_image_with_geometry_string with a geometry string like "WxH!" where <tt>dimensions</tt> are [W,H]. The resulting image size will be exactly widthxheight - aspect ratios are likely to break. Use geometry strings for better control over the generated images.
    def transform_image_with_array(model_instance, img, dimensions)
      transform_image_with_geometry_string(img, dimensions.join('x') + '!')
    end

    # calls #transform_image_with_custom_method (implemented on Image Engines)
    # first checks that a valid custom method exists
    def transform_image_with_symbol(model_instance, img, symbol)
      raise NoMethodError.new("'is_attachment' expects a method named '#{symbol}' to be defined.") unless model_instance.respond_to?(symbol)
      raise ArgumentError.new("'is_attachment' expects a method named '#{symbol}' to have a single paramater to take an image.") unless model_instance.method(symbol).arity.eql?(1)
      transform_image_with_custom_method(model_instance, img, symbol)
    end

    # Called when image_versions is something like :image_versions => {:custom => :custom_method} (Expects custom_method to be defined on <tt>model_instance</tt>)
    def transform_image_with_custom_method(model_instance, img, symbol)
      raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("Abstract Method - please override.")
    end

    # Called when image_versions is something like :image_versions => {:thumb => "50x60!"}
    def transform_image_with_geometry_string(img, geometry_string)
      raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("Abstract Method - please override.")
    end

    # Should yield an image object to the passed <tt>&block</tt>.
    def with_image(model_instance, &block)
      raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("Abstract Method - please override.")
    end
    # Will yield just like #with_image - and afterwards will set properties (width/height/file_size/content_type) on <tt>model_instance</tt>
    def with_image_then_inspect(model_instance, &block)
      raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("Abstract Method - please override.")
    end

    # Will set properties (width/height) on <tt>model_instance</tt> using <tt>img</tt> 
    def grab_dimensions_from_image(model_instance, img)
      raise PeelMeAGrape::IsAttachment::OperationNotSupportedError.new("Abstract Method - please override.")
    end
  end
end
