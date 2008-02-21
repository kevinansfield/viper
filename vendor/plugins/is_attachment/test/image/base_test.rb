require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))

module PeelMeAGrape::IsAttachment::Image
  class BaseTest < Test::Unit::TestCase
    def setup
      @cropper = PeelMeAGrape::IsAttachment::Transformer::Cropper.new(:width => 50, :height => 60)
      @engine = Base.new(AttachmentWithImageVersions)
      @attachment = AttachmentWithImageVersions.new
      @attachment.is_attachment_image_engine = @engine
    end

    def test_string_image_version_option
      @attachment.expects(:image_version_option).returns("50x50")
      @engine.expects(:transform_image_with_geometry_string).with(@img, "50x50")
      @engine.transform_image(@attachment, @img)
    end

    def test_fixnum_image_version_option
      @attachment.expects(:image_version_option).returns(50)
      @engine.expects(:transform_image_with_array).with(@attachment, @img, [50, 50])
      @engine.transform_image(@attachment, @img)
    end

    def test_transform_image_with_array_uses_geometry_string
      with_mock_img(@attachment) do |img|
        @engine.expects(:transform_image_with_geometry_string).with(img, "50x60!")
        @engine.transform_image_with_array(@attachment, img, [50, 60])
      end
    end

    def test_fixnum_array_image_version_option
      @attachment.expects(:image_version_option).returns([50, 60])
      @engine.expects(:transform_image_with_array).with(@attachment, @img, [50, 60])
      @engine.transform_image(@attachment, @img)
    end

    def test_symbol_image_version_option
      @attachment.expects(:image_version_option).returns(:custom)
      @attachment.expects(:custom).never
      mock_method = mock(:arity => 1)
      @attachment.expects(:method).with(:custom).returns(mock_method)
      @engine.expects(:transform_image_with_custom_method).with(@attachment, @img, :custom)
      @engine.transform_image(@attachment, @img)
    end

    def test_transformer_image_version_option
      @attachment.expects(:image_version_option).returns(@cropper)
      @engine.expects(:transform_image_with_custom_transformer).with(@attachment, @img, @cropper)
      @engine.transform_image(@attachment, @img)
    end

    def test_transform_image_with_custom_transformer
      @engine.class.expects(:name).returns(:rmagick)
      @cropper.expects(:transform_with_rmagick).with(@engine, @img, @attachment)
      @engine.transform_image_with_custom_transformer(@attachment, @img, @cropper)
    end

    def test_calls_different_custom_transformer_method_depending_on_configured_image_engine
      @engine.class.expects(:name).returns(:mini_magick)
      @cropper.expects(:transform_with_mini_magick).with(@engine, @img, @attachment)
      @engine.transform_image_with_custom_transformer(@attachment,@img, @cropper)
    end

    def test_transform_image_with_symbol_raises_when_no_method
      assert_raises(NoMethodError, "'is_attachment' expects a method named '#{:bad_custom_method}' to be defined.") do
        @engine.transform_image_with_symbol(@attachment, mock,:bad_custom_method)
      end
    end

    def test_transform_image_with_symbol_raises_when_transform_method_has_wrong_arity
      mock_method = mock(:arity => 0)
      attachment = AttachmentWithCustomImageVersions.new
      attachment.expects(:method).with(:custom).returns(mock_method)
      assert_raises(ArgumentError, "'is_attachment' expects a method named 'custom' to have a single paramater to take an image.") do
        @engine.transform_image_with_symbol(attachment, mock,:custom)
      end
    end
  end
end