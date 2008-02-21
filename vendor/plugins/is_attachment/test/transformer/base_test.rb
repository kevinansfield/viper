require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))

module PeelMeAGrape::IsAttachment::Transformer
  class BaseTest < Test::Unit::TestCase
    def setup
      @transformer = Base.new
    end

    def test_instance_methods
      assert_equal Base::InstanceMethods, @transformer.module_to_include
    end

    def test_method_missing_for_transform_with_valid_image_engine
      PeelMeAGrape::IsAttachment.image_engines.keys.each do |engine|
        assert_raises(TransforNotImplementedForEngineError) do
          method = "transform_with_#{engine}"
          @transformer.send(method)
        end
      end
      assert_raises(NoMethodError) {@transformer.transform_with_mysterious_engine}
    end
  end
end