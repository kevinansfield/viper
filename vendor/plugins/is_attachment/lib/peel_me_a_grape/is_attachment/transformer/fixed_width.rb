module PeelMeAGrape::IsAttachment 
  module Transformer # :nodoc:
    # Simple Transformer to resize an image to a fixed width - adjusting its height to maintain its original aspect ratio
    class FixedWidth < Base
      attr_accessor :width

      # Fixed <tt>width</tt> 
      def initialize(width)
        raise ArgumentError.new("width must be a Fixnum") unless width.is_a?(Fixnum)
        self.width = width
      end

      # Resizes image using geometry string of form "#{width}x" - See http://www.simplesystems.org/RMagick/doc/imusage.html#geometry
      def transform_with_rmagick(engine, img, attacment_object)
        engine.transform_image_with_geometry_string(img, "#{width}x")
      end

      # Resizes image using geometry string of form "#{width}x" - See http://www.simplesystems.org/RMagick/doc/imusage.html#geometry
      def transform_with_mini_magick(engine, img, attacment_object)
        engine.transform_image_with_geometry_string(img, "#{width}x")
      end
    end
  end
end