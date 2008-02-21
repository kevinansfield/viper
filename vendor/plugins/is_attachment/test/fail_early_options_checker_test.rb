require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

module PeelMeAGrape::IsAttachment
  class FailEarlyOptionsCheckerTest < Test::Unit::TestCase
    def setup
      @checker = FailEarlyOptionsChecker
    end

    def test_checks_minimal_required_columns
      model = mock(:column_names => ['id'])
      assert_raises AttachmentColumnsError, "'is_attachment' requires at the very minimum a filename column" do
        @checker.check_required_columns(model, {})
      end
    end

    def test_check_base_version_id_and_version_name_required_if_versions
      model = stub(:column_names => ['id', 'filename'])
      assert_raises AttachmentColumnsError, "'is_attachment' requires the following columns (base_version_id, version_name) if your model creats multiple versions (ie. uses :image_versions option)" do
        @checker.check_required_columns(model, :image_versions => {:thumb => '50'})
      end
      model = stub(:column_names => ['id', 'filename', 'base_version_id', 'version_name'], :columns => [mock(:name => 'version_name', :text? => true)])
      assert_nothing_raised { @checker.check_required_columns(model, :image_versions => {:thumb => '50'})}
    end

    def test_check_version_name_of_type_string
      bad_version_name_column = mock(:name => 'version_name', :text? => false)
      valid_version_name_column = mock(:name => 'version_name', :text? => true)
      model = stub(:column_names => ['id', 'filename', 'base_version_id', 'version_name'], :columns => [bad_version_name_column])
      assert_raises AttachmentColumnsError, "'is_attachment' column :version_name must be of type :string" do
        @checker.check_required_columns(model, :image_versions => {:thumb => '50'})
      end
      model = stub(:column_names => ['id', 'filename', 'base_version_id', 'version_name'], :columns => [valid_version_name_column])
      assert_nothing_raised{  @checker.check_required_columns(model, :image_versions => {:thumb => '50'}) }
    end

    def test_bad_image_engine
      assert_raises(UnregisteredExtensionError) do
        @checker.check_image_engine_options(:image_engine => :bad_engine)
      end
    end

    def test_raises_when_storage_engine_doesnt_exist
      assert_raises(UnregisteredExtensionError) do
        @checker.check_storage_engine_options(:storage_engine => :bad_engine)
      end
    end

    def test_raises_if_unexpected_option_received
      assert_raises ArgumentError, "Unknown key(s): unexpected_option" do
        @checker.check(mock(), :unexpected_option => 'SOME VAL')
      end
    end

    def test_valid_validate_options_keys
      assert_raises ArgumentError, "Invalid option(s) 'bad_option' for :validate - valid options are (width, height, file_size, content_type, file_extension, required, min_width, min_height, max_width, max_height, max_file_size)" do
        @checker.check_validate_keys(:validate => {:width => 50, :height => 60, :bad_option => 70})
      end
    end

    def test_check_validate_keys_checks_values
      assert_raises(ArgumentError){@checker.check_validate_values(:validate => {:required => 1})}
      assert_raises(ArgumentError){@checker.check_validate_values(:validate => {:width => "50"})}
      assert_raises(ArgumentError, "Invalid content_type validation paramater") do
        @checker.check_validate_values(:validate => {:content_type => :unexpected_option_symbol})
      end
    end

    def test_check_validate_keys_no_sideeffects
      validate_options = {:content_type => 'application/pdf'}
      options = {:validate => validate_options.dup}
      @checker.check_validate_values(options)
      assert_equal(validate_options, options[:validate])
    end

    def test_raise_argument_error_if_width_height_file_size_not_fixnum_or_range
      assert_raises(ArgumentError, "Invalid Validation Paramater Type - (:width - String)") do
        @checker.check_validate_values(:validate => {:width => "invalid"})
      end
    end

    def test_raise_for_ambiguous_hash_config
      assert_raises(ArgumentError, "Ambiguous Configuration - hash should only contain one entry. [:cropper, :unknown]") do
        @checker.check_image_versions_options(:image_versions => {:cropped => {:cropper => {:width => 50, :height => 50}, :unknown => {:param => 'val'}}})
      end
    end

    def test_transform_image_with_unregistered_custom_transformer
      assert_raises(ArgumentError, "No Custom Transformer registered with name: 'unregistered'") do
        @checker.check_image_versions_options(:image_versions => {:cropped => { :unregistered => {:param => 'val'}}})
      end
    end
  end
end