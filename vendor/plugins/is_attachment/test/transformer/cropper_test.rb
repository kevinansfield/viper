require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))

module PeelMeAGrape::IsAttachment::Transformer
  class CropperTest < Test::Unit::TestCase
    def setup
      @cropper = Cropper.new(:width => 500, :height => 600)
      @mock_engine = mock()
    end

    def test_initialize
      assert_raises(ArgumentError) {Cropper.new({})}
      assert_nothing_raised {
        cropper = Cropper.new(50.0)
        assert_equal 50, cropper.width
        assert_equal 50, cropper.height
      }
      assert_nothing_raised {
        cropper = Cropper.new([500, 600])
        assert_equal 500, cropper.width
        assert_equal 600, cropper.height
      }
      assert_nothing_raised {
        cropper = Cropper.new(50.0, 60)
        assert_equal 50, cropper.width
        assert_equal 60, cropper.height
      }
      assert_nothing_raised {Cropper.new({:width => 50, :height => 60})}
    end

    def test_module_to_include
      assert_equal Cropper::InstanceMethods, @cropper.module_to_include
    end

    def test_cropper_restrictions
      assert_equal({:min_width => 500, :min_height => 600, :ratio_dim =>{:x => 500, :y => 600}}, @cropper.cropper_restrictions)
    end

    def test_cropper_restrictions_instance_method
      attachment = AttachmentWithCropperVersions.new
      assert_nil attachment.cropper_restrictions
      attachment.stubs(:is_base_version?).returns(false)
      attachment.stubs(:version_name).returns(:cropped)
      assert_equal({:min_width => 50, :min_height => 60, :ratio_dim =>{:x => 50, :y => 60}}, attachment.cropper_restrictions)
      attachment.stubs(:version_name).returns(:big_cropped)
      assert_equal({:min_width => 500, :min_height => 600, :ratio_dim =>{:x => 500, :y => 600}}, attachment.cropper_restrictions)
    end

    def test_transform_with_rmagick_with_no_crop_options
      model = stub(:crop_options => nil)
      img = mock()
      img.expects(:thumbnail!).with(500, 600)
      @cropper.transform_with_rmagick(@mock_engine, img, model)
    end

#  lots of cases to test..... bigger, exact same size, longer, wider, etc...

    # if model widt/height ratio > cropper then resize the image to the cropper height height
=begin
          if (width.to_f/height.to_f) > (target_width.to_f / target_height.to_f)
            img.resize("x#{target_height}")
          else
            img.resize("#{target_width}x")
          end
          img.crop("#{target_width}x#{target_height}+0+0")
todo - test with mini magick and rmagick ....
=end

    def test_cropper_will_default_to_cropping_biggest_and_most_centered_portion_of_image
      model = stub(:crop_options => nil, :width => 3000, :height => 1000)
      img = mock()
      img.expects(:resize).with("x600")
      img.expects(:crop).with("500x600+0+0")
      @cropper.transform_with_rmagick(@mock_engine, img, model)
    end

    def test_transform_with_rmagick_with_crop_options
      model = stub(:crop_options => {:x1 => 10, :y1 => 20, :width => 1000, :height => 1200})
      img = mock()
      img.expects(:crop!).with(10, 20, 1000, 1200, true)
      img.expects(:resize!).with(500, 600)
      @cropper.transform_with_rmagick(@mock_engine, img, model)
    end

    def test_transform_with_mini_magick_with_no_crop_options
      model = stub(:crop_options => nil)
      img = mock()
      img.expects(:thumbnail).with("500x600!").returns("return code")
      assert_equal img, @cropper.transform_with_mini_magick(@mock_engine, img, model)
    end

    def test_transform_with_mini_magick_with_crop_options
      model = stub(:crop_options => {:x1 => 10, :y1 => 20, :width => 1000, :height => 1200})
      img = mock()
      img.expects(:crop).with("1000x1200+10+20")
      img.expects(:resize).with("500x600!")
      @cropper.transform_with_mini_magick(@mock_engine, img, model)
    end

    def test_included_calls_serialize_crop_options
      base = mock(:column_names => ['crop_options'])
      base.expects(:serialize).with(:crop_options)
      Cropper::InstanceMethods.included(base)
    end

    def test_included_raises_if_we_dont_have_crop_options_column
      base = mock(:column_names => [])
      assert_raises(PeelMeAGrape::IsAttachment::AttachmentColumnsError, "your model must have 'crop_options' column to use Cropper") do
        Cropper::InstanceMethods.included(base)
      end
    end

    def test_overlay
      overlay_image = image_upload("overlay.png").path
      assert_nothing_raised {
        @cropper = Cropper.new(:width => 200, :height => 60, :overlay => overlay_image)
        assert_equal overlay_image, @cropper.overlay
      }
      mock_overlay_image = mock()
      Magick::Image.stubs(:read).returns([mock_overlay_image])
      model = stub(:crop_options => nil)
      img = mock()
      img.expects(:thumbnail!).with(200, 60)
      img.expects(:composite!).with(mock_overlay_image, Magick::CenterGravity, Magick::OverCompositeOp)
      @cropper.transform_with_rmagick(@mock_engine, img, model)
    end
  end
end