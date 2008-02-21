module PeelMeAGrape::IsAttachment 
  module Transformer # :nodoc:
    # Simple Transformer to resize an image to a fixed height - adjusting its width to maintain its original aspect ratio
    class FixedHeight < Base
      attr_accessor :height

      # Fixed <tt>height</tt>
      def initialize(height)
        raise ArgumentError.new("height must be a Fixnum") unless height.is_a?(Fixnum)
        self.height = height
      end

      # Resizes image using geometry string of form "x#{height}" - See http://www.simplesystems.org/RMagick/doc/imusage.html#geometry
      def transform_with_rmagick(engine, img, attacment_object)
        engine.transform_image_with_geometry_string(img, "x#{height}")
      end

      # Resizes image using geometry string of form "x#{height}" - See http://www.simplesystems.org/RMagick/doc/imusage.html#geometry
      def transform_with_mini_magick(engine, img, attacment_object)
        engine.transform_image_with_geometry_string(img, "x#{height}")
      end
    end
  end
end