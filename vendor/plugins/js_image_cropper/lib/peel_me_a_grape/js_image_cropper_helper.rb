# js_image_cropper rails plugin
#
# Copyright (c) 2007 Peelmeagrape, released under the MIT license
module PeelMeAGrape # :nodoc:
  module JsImageCropperHelper
    # Returns an html script tag with javascript to initialise a Image Cropper for the img with id="+img_id+"
    #
    # You can add +cropper_options+ that will be used to configure the actial Cropper object. (See #cropper_javascript)
    #
    # You can also configure a number of options using +other_options+
    #
    # +other_options+:
    # *  <tt>:include_default_on_end_crop_javascript</tt> - set to true and javascript outputted will include a function to update the values of a form (See #default_on_end_crop_javascript).
    # *  <tt>:on_window_load</tt> - Cropper tag will be initialised using and an Event observer on widow load.  true by default.
    #
    # ===== Examples
    #  cropper_javascript_tag('cropMe')
    #  cropper_javascript_tag('cropMe', {:preview_wrap => 'previewWrap'})
    #  cropper_javascript_tag('cropMe', {:preview_wrap => 'previewWrap', :on_load_coords => @image.crop_options}, {:include_default_on_end_crop_javascript => true }) 
    def cropper_javascript_tag(img_id, cropper_options = {}, other_options = {})
      extra = ""
      if other_options[:include_default_on_end_crop_javascript]
        extra = "#{default_on_end_crop_javascript}\n"
        cropper_options[:on_end_crop] = 'onEndCrop'
      end
      other_options[:on_window_load] = true if other_options[:on_window_load].nil?
      other_options[:on_window_load] ? javascript_tag(extra + on_window_load(cropper_javascript(img_id,cropper_options))) : javascript_tag(extra + cropper_javascript(img_id,cropper_options))
    end

    # +cropper_options+
    # *  <tt>:min_width</tt> - minimum width of crop
    # *  <tt>:min_height</tt> - minimum height of crop
    # *  <tt>:max_width</tt> - maximum width of crop
    # *  <tt>:max_height</tt> - maximum height of crop
    # *  <tt>:display_on_init</tt> - displays the crop box when initialised.  
    # *  <tt>:on_end_crop</tt> - javascript function to call when the crop is changed
    # *  <tt>:preview_wrap</tt> - id of element that a crop preview will be shown in. eg. <div id="preview_wrap"></div>
    # *  <tt>:on_load_coords</tt> - coordintes of initial crop eb. { x1: 50, x2: 150, y1: 100, y2: 200 }
    # *  <tt>:ratio_dim</tt> - ratio restriction eg. { x: 50, y: 100}
    #
    # ==== Examples
    #   cropper_javascript('cropMe')
    #       => new Cropper.Img('cropMe')
    #
    #   cropper_javascript('image_id', :min_width => 50, :min_height => 60, :max_width => 80, :max_height => 100,
    #                                  :on_load_coords => {:x1 => 50, :x2 => 150, :y1 => 100, :y2 => 200},
    #                                  :ratio_dim => {:x => 50, :y => 100}  )
    #       =>  new Cropper.Img('image_id', { maxHeight: 100, maxWidth: 80, minHeight: 60, minWidth: 50, onLoadCoords: { x1: 50, x2: 150, y1: 100, y2: 200 }, ratioDim: { x: 50, y: 100 } });
    def cropper_javascript(img_id, cropper_options = {})
      js = "new Cropper.#{cropper_class(cropper_options)}('#{img_id}'"
      js << options_string(cropper_options) unless cropper_options.empty?
      js << ");"
    end

    # Creates hidden fields for cropper[width], cropper[height], cropper[x1], cropper[x2], cropper[y1], cropper[y2].
    # The fields have id's like cropper_width, cropper_x1 etc.
    #
    # You can specify initial values for the fields with +initial_crop_options+.
    # if +initial_crop_options+ == {:x1 => 10} then the cropper[x1] field will have a value of 10.
    #
    def cropper_form_fields(initial_crop_options = {})
      html = ""
      initial_crop_options ||= {}
      ['x1','y1','x2','y2','width','height'].each do |key|
        initial_value = initial_crop_options[key.to_sym]
        html << "\n" + hidden_field_tag("cropper[#{key}]", initial_value, :id => "cropper_#{key}")
      end
      html
    end

    protected
    # Default function to be called by the Cropper after the crop is changed. Matches the convention used in #cropper_form_fields.
    # It's behaviour is to set the value of form fields for each of the cropper's values if the fields witht he conventional names and id's exist.
    def default_on_end_crop_javascript
    <<-EOT
  function onEndCrop( coords, dimensions ) {
    if($('cropper_x1' ) != null) $( 'cropper_x1' ).value = coords.x1;
    if($('cropper_y1' ) != null) $( 'cropper_y1' ).value = coords.y1;
    if($('cropper_x2' ) != null) $( 'cropper_x2' ).value = coords.x2;
    if($('cropper_y2' ) != null) $( 'cropper_y2' ).value = coords.y2;
    if($('cropper_width' ) != null) $( 'cropper_width' ).value = dimensions.width;
    if($('cropper_height') != null) $( 'cropper_height' ).value = dimensions.height;
  }
    EOT
    end

    private
      def on_window_load(block_contents)
        "Event.observe(window,'load', function() {\n#{block_contents}\n});"
      end

      def cropper_class(options)
        options[:preview_wrap].blank? ? 'Img' : 'ImgWithPreview'
      end

      def options_string(options)
        js_options = {}
        [:min_width, :min_height, :max_width, :max_height, :display_on_init, :capture_keys, :on_end_crop, :preview_wrap].each do |simple_option|
          value = options[simple_option]
          js_options[simple_option] = value unless value.nil?
        end
        js_options[:preview_wrap] = "'#{options[:preview_wrap]}'" unless options[:preview_wrap].blank?
        unless options[:on_load_coords].blank?
          options[:on_load_coords].delete_if{|k,v| ![:x1,:x2,:y1,:y2].include?(k.to_sym)}
          js_options[:onload_coords] = options_hash(options[:on_load_coords])
        end
        js_options[:ratio_dim] = options_hash(options[:ratio_dim]) unless options[:ratio_dim].blank?
        js_options_string = options_hash(js_options) {|k| k.to_s.camelize(:lower)}
        js_options_string.blank? ? "" : ", #{js_options_string}"
      end

      def options_hash(hash, &block)
        hash.empty? ? nil : '{ ' + hash.map {|k, v| k = block.call(k) unless block.nil?; "#{k}: #{v}"}.sort.join(', ') + ' }'
      end
    end
end