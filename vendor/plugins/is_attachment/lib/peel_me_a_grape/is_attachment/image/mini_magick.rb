require 'mini_magick'
module PeelMeAGrape::IsAttachment
  module Image # :nodoc:
    # Image processing engine using MiniMagick (see https://rubyforge.org/projects/mini-magick/)
    class MiniMagick < Base
      def self.name
        :mini_magick
      end

      @@content_types = {:jpg=> 'image/jpeg', :jpeg => 'image/jpeg', :gif => 'image/gif', :png => 'image/png'}

      def content_type_for_extension(extension)
        @@content_types[extension.downcase.to_sym]
      end

      # yields a MiniMagick::Image of the file to process to a block
      def with_image(model_instance, &block)
        file = model_instance.temp_path
        binary_data = ::MiniMagick::Image.from_file(file) 
        block.call(binary_data)
      end

      # yields a MiniMagick::Image (using #with_image) and with the result sets width, height, content_type and file_size of the new file. (where appropriate columns exist on your model)
      def with_image_then_inspect(model_instance, &block)
        with_image(model_instance) do |img|
          block_result = block.call(img) unless block.nil?
          img = block_result unless block_result.nil?
          grab_dimensions_from_image(model_instance, img)
          model_instance.content_type = content_type_for_extension(img[:format])
          model_instance.file_size = File.size(model_instance.temp_path)
          model_instance.temp_path = img.path
        end
      end

      # transforms using geometry string (see http://www.simplesystems.org/RMagick/doc/imusage.html#geometry).
      # Uses MiniMagick::Image.resize
      def transform_image_with_geometry_string(img, geometry_string)
        img.resize(geometry_string)
        img
      end

      # calls custom method on model to perform the processing, passes MiniMagick::Image with the base_version image file to the method
      def transform_image_with_custom_method(model_instance, img, method)
        result = model_instance.send(method, img)
        raise BadAttachmentProcessorError.new("Process method (#{method}) must return an object of type 'MiniMagick::Image' - it actually returned '#{result.class}'") unless result.kind_of?(::MiniMagick::Image)
        result
      end

      # sets the width, height and aspect ratio of the record from the attributes of the image.
      def grab_dimensions_from_image(model_instance, img)
        model_instance.width = img[:width]
        model_instance.height = img[:height]
        model_instance.aspect_ratio = model_instance.width.to_f / model_instance.height.to_f if model_instance.respond_to?(:aspect_ratio=)
      end
    end
  end
end