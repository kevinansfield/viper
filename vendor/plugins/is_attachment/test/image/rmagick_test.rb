require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))

module PeelMeAGrape::IsAttachment::Image
  class RmagickTest < Test::Unit::TestCase
    def setup
      @engine = Rmagick.new(AttachmentWithImageVersions)
      @attachment = AttachmentWithImageVersions.new
      @attachment.is_attachment_image_engine = @engine
    end

    def test_transform_image_with_geometry_string
      with_mock_img(@attachment) do |img|
        img.expects(:change_geometry).with("50x50")
        @engine.transform_image_with_geometry_string(img, "50x50")
      end
    end

    def test_transform_image_with_custom_method
      @attachment = AttachmentWithCustomImageVersions.new
      with_mock_img(@attachment) do |img|
        @attachment.expects(:custom).with(img).returns(Magick::Image.read(image_upload.path)[0])
        @engine.transform_image_with_custom_method(@attachment, img, :custom)
      end
    end

    def test_transform_image_with_custom_method_raises_when_return_isnt_img
      @attachment = AttachmentWithCustomImageVersions.new
      with_mock_img(@attachment) do |img|
        @attachment.expects(:custom).with(img).returns("BLAH")
        assert_raises(PeelMeAGrape::IsAttachment::BadAttachmentProcessorError) do
          @engine.transform_image_with_custom_method(@attachment, img, :custom)
        end
      end
    end

    def test_with_image
      @enters_block = false
      @attachment.temp_path = image_upload.path
      @engine.with_image(@attachment) do |img|
        @enters_block = true
        assert img.kind_of?(Magick::Image)
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
      @engine.with_image_then_inspect(@attachment) do |img|
        assert_nil @attachment.width
        assert_nil @attachment.height
        assert_nil @attachment.file_size
        assert_nil @attachment.content_type
        img
      end
      assert @attachment.file_size > 0, @attachment.file_size
      assert_equal 50, @attachment.width
      assert_equal 64, @attachment.height
      assert_equal 'image/png', @attachment.content_type
    end
  end
end