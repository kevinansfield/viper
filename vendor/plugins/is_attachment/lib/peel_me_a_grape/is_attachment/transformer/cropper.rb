module PeelMeAGrape::IsAttachment 
  module Transformer # :nodoc:
    # Cropper will process your image to fit an exact width and height - if your model has crop options set - then the image generated will be a crop of the original image scaled to fit the exact width and height.
    # ==== Required Columns
    # * crop_options (text or varchar) - used to store the coordinates of the crop using rails serialization
    class Cropper < Base
      attr_accessor :width, :height, :overlay

      # <tt>options</tt> can either be:
      # size (equal width and height)
      #    Cropper.new(50)
      # width and height
      #    Cropper.new(50,60)
      # an array with width and height
      #    Cropper.new([50,60])
      # a hash with :width and :height entries
      #    Cropper.new(:width => 50, :height => 60)
      def initialize(*options)
        options = options.last if options.last.is_a? Array
        if options.last.is_a? Hash
          options = options.last
          raise ArgumentError.new("Required keys - :width, :height") unless options.include?(:width) && options.include?(:height)
          self.width = options[:width]
          self.height = options[:height]
          self.overlay = options[:overlay]
        else
          self.width = options.first.to_i
          self.height = options.last.to_i
        end
      end

      #    Cropper.new([50,60])
      # gives cropper restrictions of
      #    { :min_width => 50, :min_height => 60, :ratio_dim => { :x => 50, :y => 60 } }
      # These values are very useful for using with - js_image_cropper http://peelmeagrape.net/projects/js_image_cropper/ - our plugin that helps simplifying usage of
      # http://www.defusion.org.uk/code/javascript-image-cropper-ui-using-prototype-scriptaculous/ with ruby on rails.
      def cropper_restrictions
        {:min_width => self.width, :min_height => self.height, :ratio_dim => {:x => self.width, :y => self.height}}
      end

      # performs the cropping when using rmagick image processing engine.
      # if crop_options is nil? then the image is resized to fit the dimensions.
      # if crop options is set then they are used to first crop the image then resize it.
      def transform_with_rmagick(engine, img, attacment_object)
        crop_options = attacment_object.crop_options
        unless attacment_object.crop_options.blank?
          img.crop!(crop_options[:x1].to_i, crop_options[:y1].to_i, crop_options[:width].to_i, crop_options[:height].to_i, true)
          img.resize!(self.width, self.height)
        else
          img.thumbnail!(self.width, self.height)
        end
        unless self.overlay.blank?
          overlay = Magick::Image.read(self.overlay).first
          img.composite!(overlay, Magick::CenterGravity, Magick::OverCompositeOp )
        end
        img
      end

      # same behaviour as #transform_with_rmagick - using mini_magick
      def transform_with_mini_magick(engine, img, attacment_object)
        crop_options = attacment_object.crop_options
        unless attacment_object.crop_options.blank?
          img.crop("#{crop_options[:width].to_i}x#{crop_options[:height].to_i}+#{crop_options[:x1].to_i}+#{crop_options[:y1].to_i}")
          img.resize("#{self.width}x#{self.height}!")
        else
          img.thumbnail("#{self.width}x#{self.height}!")
        end
        img
      end

      module InstanceMethods
        # When InstanceMethods gets included in the attachment model class it will call
        #    base.serialize :crop_options
        def self.included(base)
          raise AttachmentColumnsError.new("your model must have 'crop_options' column to use Cropper") unless base.column_names.include?('crop_options')
          base.serialize :crop_options
        end

        # Method added to your attachment model class that returns the restrictions imposed by the cropper.
        # see Cropper.cropper_restrictions
        def cropper_restrictions
          unless is_base_version?
            cropper = image_version_options[self.version_name.to_sym]
            cropper.respond_to?(:cropper_restrictions) ? cropper.cropper_restrictions : nil
          end
        end
      end
    end
  end
end