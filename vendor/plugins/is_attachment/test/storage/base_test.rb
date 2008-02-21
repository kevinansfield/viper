require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))

module PeelMeAGrape::IsAttachment::Storage
  class BaseTest < Test::Unit::TestCase
    def setup
      @attachment_class = mock()
    end

    def test_attachment_class
      Base.any_instance.expects(:on_init)
      base = Base.new(@attachment_class)
      assert_equal @attachment_class, base.attachment_class
    end

    def test_interface_raise_errors
      base = Base.new(@attachment_class)
      [:persist_to_storage, :public_path, :copy_to_temp_file, :remove_from_storage].each do |method|
        assert_raises(PeelMeAGrape::IsAttachment::OperationNotSupportedError){base.send(method, nil)}
      end
    end

    def test_on_init_called
      Base.any_instance.expects(:attachment_class=).with(@attachment_class)
      Base.any_instance.expects(:on_init)
      Base.new(@attachment_class)
    end
  end
end