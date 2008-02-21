require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))

module PeelMeAGrape::IsAttachment::Transformer
  class FixedWidthTest < Test::Unit::TestCase
    def setup
      @cropper = FixedWidth.new(50)
      @engine = mock()
      @img = mock()
    end

    def test_initialize
      assert_raises(ArgumentError, "width must be a Fixnum") {FixedWidth.new("50")}
    end

    def test_transform_with_rmagick
      @engine.expects(:transform_image_with_geometry_string).with(@img, "50x")
      @cropper.transform_with_rmagick(@engine, @img, nil)
    end

    def test_transform_with_mini_magick
      @engine.expects(:transform_image_with_geometry_string).with(@img, "50x")
      @cropper.transform_with_mini_magick(@engine, @img, nil)
    end
  end
end