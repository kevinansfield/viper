require 'RMagick'
module PeelMeAGrape::IsAttachment
  module Image # :nodoc:
    # Image processing engine using RMagick (see http://rmagick.rubyforge.org/)
    class Rmagick < Base
      def self.name
        :rmagick
      end
      
      # calls custom method on model to perform the processing, passes MiniMagick::Image with the base_version image file to the method
      def transform_image_with_custom_method(model_instance, img, method)
        result = model_instance.send(method, img)
        raise BadAttachmentProcessorError.new("Process method (#{method}) must return an object of type 'Magick::Image' - it actually returned '#{result.class}'") unless result.kind_of?(Magick::Image)
        result
      end

      # transforms using geometry string (see http://www.simplesystems.org/RMagick/doc/imusage.html#geometry).
      # Uses Magick::Image.change_geometry
      def transform_image_with_geometry_string(img, geometry_string)
        img.change_geometry(geometry_string) { |cols, rows, image| image.resize!(cols, rows) }
      end

      # yields a Magick::Image (using #with_image) and with the result sets width, height, content_type and file_size of the new file. (where appropriate columns exist on your model)
      def with_image_then_inspect(model_instance, &block)
        with_image(model_instance) do |img|
          block_result = block.call(img) unless block.nil?
          img = block_result unless block_result.nil?
          model_instance.temp_path = create_empty_temp_file.path
          img.write(img.format+":"+ model_instance.temp_path)
          grab_dimensions_from_image(model_instance, img)
          model_instance.file_size = File.size(model_instance.temp_path)
          model_instance.content_type = img.mime_type
        end
      end

      # yields a Magick::Image of the file to process to a block
      def with_image(model_instance, &block)
        file = model_instance.temp_path
        binary_data = Magick::Image.read(file).first
        block.call(binary_data)
      end

      # sets the width, height and aspect ratio of the record from the attributes of the image.
      def grab_dimensions_from_image(model_instance, img)
        model_instance.width = img.columns
        model_instance.height = img.rows
        model_instance.aspect_ratio = img.columns.to_f / img.rows.to_f if model_instance.respond_to?(:aspect_ratio=)
      end
    end
  end
end