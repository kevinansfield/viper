require 'rubygems'
require 'test/unit'
require File.dirname(__FILE__) + '/../lib/peel_me_a_grape/js_image_cropper_helper'
require 'active_support'
require 'action_controller'
require 'action_view'

class JsImageCropperHelperTest < Test::Unit::TestCase
  include PeelMeAGrape::JsImageCropperHelper
  include ActiveSupport::CoreExtensions::String
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::JavaScriptHelper

  def test_simplest_case
    assert_equal "new Cropper.Img('image_id');", cropper_javascript('image_id')
  end

  def test_min_width_height
    assert_equal "new Cropper.Img('image_id', { minWidth: 50 });", cropper_javascript('image_id', :min_width => 50)
    assert_equal "new Cropper.Img('image_ID', { minHeight: 60, minWidth: 50 });", cropper_javascript('image_ID', {:min_width => 50, :min_height => 60})
    assert_equal "new Cropper.Img('image_id', { maxHeight: 100, maxWidth: 80, minHeight: 60, minWidth: 50 });", cropper_javascript('image_id', {:min_width => 50, :min_height => 60, :max_width => 80, :max_height => 100})
  end

  def test_boolean_options
    assert_equal "new Cropper.Img('image_id', { captureKeys: true, displayOnInit: false });", cropper_javascript('image_id', :display_on_init => false, :capture_keys => true )
  end

  def test_on_end_crop
    assert_equal "new Cropper.Img('image_id', { onEndCrop: onEndCrop });", cropper_javascript('image_id', :on_end_crop => :onEndCrop )
    assert_equal "new Cropper.Img('image_id', { onEndCrop: onEndCrop });", cropper_javascript('image_id', :on_end_crop => 'onEndCrop' )
    assert_equal "new Cropper.Img('image_id', { onEndCrop: after_crop });", cropper_javascript('image_id', :on_end_crop => 'after_crop' )
  end

  def test_ratio_dim
    assert_equal "new Cropper.Img('image_id', { ratioDim: { x: 50, y: 100 } });", cropper_javascript('image_id', :ratio_dim => {:x => 50, :y => 100} )
  end

  def test_on_load_coords
    assert_equal "new Cropper.Img('image_id', { onLoadCoords: { x1: 50, x2: 150, y1: 100, y2: 200 } });", cropper_javascript('image_id', :on_load_coords => {:x1 => 50, :x2 => 150, :y1 => 100, :y2 => 200} )
  end

  def test_with_preview_option
    assert_equal "new Cropper.ImgWithPreview('image_id', { previewWrap: 'crop_preview' });", cropper_javascript('image_id', :preview_wrap => 'crop_preview')
    assert_equal "new Cropper.ImgWithPreview('image_id', { previewWrap: 'crop_preview' });", cropper_javascript('image_id', :preview_wrap => :crop_preview)
  end

  def test_on_window_load
    assert_equal "Event.observe(window,'load', function() {\nsome stuff\n});", on_window_load("some stuff")
  end

  def test_string_params_handled_appropriately
    assert_equal "new Cropper.Img('image_id', { maxHeight: 100, maxWidth: 80, minHeight: 60, minWidth: 50, onLoadCoords: { x1: 50, x2: 150, y1: 100, y2: 200 }, ratioDim: { x: 50, y: 100 } });",
       cropper_javascript('image_id', :min_width => "50", :min_height => "60", :max_width => "80", :max_height => "100",
                                      :on_load_coords => {:x1 => "50", :x2 => "150", :y1 => "100", :y2 => "200"},
                                      :ratio_dim => {:x => "50", :y => "100"}  )
  end

  def test_cropper_javascript_tag
    # with options to include default onEndCrop, and to wrap in a tag
    assert_equal javascript_tag(cropper_javascript('image')), cropper_javascript_tag('image',{},{:on_window_load => false})
    assert_equal javascript_tag(on_window_load(cropper_javascript('image', {:min_width => 50}))), cropper_javascript_tag('image', {:min_width => 50}, {:include_default_on_end_crop_javascript => false })
    assert_equal javascript_tag(default_on_end_crop_javascript + "\n"+ on_window_load(cropper_javascript('image', {:min_width => 50, :on_end_crop => 'onEndCrop'}))), cropper_javascript_tag('image', {:min_width => 50}, {:include_default_on_end_crop_javascript => true })
    assert_equal javascript_tag(default_on_end_crop_javascript + "\n"+ cropper_javascript('image', {:min_width => 50, :on_end_crop => 'onEndCrop'})), cropper_javascript_tag('image', {:min_width => 50}, {:on_window_load => false, :include_default_on_end_crop_javascript => true })
  end

  def test_default_on_end_crop_javascript
    expected = <<-EOT
  function onEndCrop( coords, dimensions ) {
    if($('cropper_x1' ) != null) $( 'cropper_x1' ).value = coords.x1;
    if($('cropper_y1' ) != null) $( 'cropper_y1' ).value = coords.y1;
    if($('cropper_x2' ) != null) $( 'cropper_x2' ).value = coords.x2;
    if($('cropper_y2' ) != null) $( 'cropper_y2' ).value = coords.y2;
    if($('cropper_width' ) != null) $( 'cropper_width' ).value = dimensions.width;
    if($('cropper_height') != null) $( 'cropper_height' ).value = dimensions.height;
  }
    EOT
    assert_equal expected, default_on_end_crop_javascript
  end

  def test_cropper_form_fields
    expected = <<-EOT
<input id="cropper_x1" name="cropper[x1]" type="hidden" />
<input id="cropper_y1" name="cropper[y1]" type="hidden" />
<input id="cropper_x2" name="cropper[x2]" type="hidden" />
<input id="cropper_y2" name="cropper[y2]" type="hidden" />
<input id="cropper_width" name="cropper[width]" type="hidden" />
<input id="cropper_height" name="cropper[height]" type="hidden" />
    EOT
    assert_equal expected.strip, cropper_form_fields.strip
  end

  
  def test_cropper_form_fields_with_initial_values
    expected = <<-EOT
<input id="cropper_x1" name="cropper[x1]" type="hidden" value="1" />
<input id="cropper_y1" name="cropper[y1]" type="hidden" value="3" />
<input id="cropper_x2" name="cropper[x2]" type="hidden" value="2" />
<input id="cropper_y2" name="cropper[y2]" type="hidden" value="4" />
<input id="cropper_width" name="cropper[width]" type="hidden" value="5" />
<input id="cropper_height" name="cropper[height]" type="hidden" value="6" />
    EOT
    assert_equal expected.strip, cropper_form_fields({:x1 => 1, :x2 => 2, :y1 => 3, :y2 => 4, :width => 5, :height => 6}).strip
  end
end