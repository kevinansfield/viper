module PeelMeAGrape::IsAttachment::Transformer # :nodoc:
  class TransforNotImplementedForEngineError < StandardError # :nodoc:
  end

  # Extend this base class to implement your own custom image transformers. (eg Cropper)
  #
  # Transformers are ideal when ever you want to reuse the same transforming logic in more than one place. (instead of having the same processing logic littering your models)
  #
  # when you configure your model to create an image_version using a custom processor - eg.
  #
  #    is_attachment :image_versions => { :cropped_thumb => { :cropper => [60,80] } }
  #
  # an instance of the Cropper transformer will be created (using [60,80] as paramater in this instance). And when the version is being created the cropper will have a method transform_with_rmagick(img, engine, attachment_model). if you are using a different image procssing engine, eg mini_magick, then transform_with_mini_magick will be called instead.
  class Base
    # catch method missing for transform_with_ methods for valid image processing engines.
    def method_missing(method_id, *args)
      match = /^transform_with_([_a-zA-Z]\w*)$/.match(method_id.to_s)
      if match && PeelMeAGrape::IsAttachment.image_engines.keys.include?(match.captures.first.to_sym)
        raise TransforNotImplementedForEngineError.new
      else
        super
      end
    end

    # by default is_attachment will try to include a module provided by the transformer in your models class. By default it will be a module called InstanceMethods.
    def module_to_include
      eval(self.class.to_s + "::InstanceMethods")
    end

    module InstanceMethods # :nodoc:
    end
  end
end