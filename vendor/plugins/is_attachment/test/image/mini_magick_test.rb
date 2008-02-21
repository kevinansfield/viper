require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))
require 'mini_magick'

module PeelMeAGrape::IsAttachment
  if Object.const_defined?(:MiniMagick)
    class MiniMagickTest < Test::Unit::TestCase
      def setup
        @engine = Image::MiniMagick.new(MiniMagickAttachment)
        @attachment = MiniMagickAttachment.new
        @attachment.is_attachment_image_engine = @engine
      end

      def test_with_image
        @enters_block = false
        @attachment.temp_path = image_upload.path
        @attachment.with_image do |img|
          @enters_block = true
          assert img.kind_of?(MiniMagick::Image)
        end
        assert @enters_block, 'Expected to call the block'
      end

      def test_with_image_then_inspect
        @attachment.temp_path = image_upload.path
        @engine.expects(:with_image).with(@attachment)
        @engine.with_image_then_inspect(@attachment) {|img|}
      end

      def test_with_image_then_inspect_sets_attributes
        @attachment.temp_path = image_upload.path
        @attachment.with_image_then_inspect do |img|
          assert_nil @attachment.width
          assert_nil @attachment.height
          assert_nil @attachment.file_size
          assert_nil @attachment.content_type
          @attachment.expects(:temp_path=).with(img.path)
          img
        end
        assert_equal 50, @attachment.width
        assert_equal 64, @attachment.height
        assert @attachment.file_size > 0
        assert_equal 'image/png', @attachment.content_type
      end

      def test_transform_image_with_geometry_string
        with_mock_img(@attachment) do |img|
          img.expects(:resize).with("50x50").returns("return code")
          assert_equal img, @engine.transform_image_with_geometry_string(img, "50x50")
        end
      end

      def test_transform_image_with_custom_method
        with_mock_img(@attachment) do |img|
          @attachment.expects(:custom).with(img).returns(MiniMagick::Image.from_file(image_upload.path))
          @engine.transform_image_with_custom_method(@attachment, img, :custom)
        end
      end

      def test_transform_image_with_custom_method_raises_when_return_isnt_img
        with_mock_img(@attachment) do |img|
          @attachment.expects(:custom).with(img).returns("BLAH")
          assert_raises(PeelMeAGrape::IsAttachment::BadAttachmentProcessorError) do
            @engine.transform_image_with_custom_method(@attachment, img, :custom)
          end
        end
      end

      def test_grab_dimensions_from_image
        with_mock_img(@attachment) do |img|
          img.expects(:[]).with(:width).returns(100)
          img.expects(:[]).with(:height).returns(200)
          @attachment.expects(:width=).with(100)
          @attachment.expects(:height=).with(200)
          @attachment.expects(:width).returns(100)
          @attachment.expects(:height).returns(200)
          @attachment.expects(:aspect_ratio=).with(0.5)
          @attachment.grab_dimensions_from_image(img)
        end
      end
    end
  else
    class MiniMagickTest < Test::Unit::TestCase
      def test_flunk
          puts "\nMiniMagick not loaded, tests not running\n"
      end
    end
  end
end