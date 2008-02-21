require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))

module PeelMeAGrape::IsAttachment::Storage
  class RemoteBaseTest < Test::Unit::TestCase
    def setup
      @attachment_class = mock()
      @engine = RemoteBase.new(@attachment_class)
      @model_instance = mock()
    end

    def test_interface_raise_errors
      [:persist_to_remote_storage, :public_path, :copy_to_temp_file, :remove_from_remote_storage].each do |method|
        assert_raises(PeelMeAGrape::IsAttachment::OperationNotSupportedError){@engine.send(method, nil)}
      end
    end

    def test_initialize
      RemoteBase.any_instance.expects(:attachment_class=).with(@attachment_class)
      RemoteBase.any_instance.expects(:on_init)
      RemoteBase.new(@attachment_class)
    end

    def test_file_system_engine
      assert_not_nil @engine.file_system_engine
      assert @engine.file_system_engine.is_a?(FileSystem)
    end

    def test_persist_to_storage_first_calls_file_system_storage_engine
      @engine.file_system_engine.expects(:persist_to_storage).with(@model_instance)
      @engine.expects(:persist_to_remote_storage).with(@model_instance)
      @engine.persist_to_storage(@model_instance)
    end

    def test_remove_from_storage_calls_file_system_remove_afterwards
      @engine.file_system_engine.expects(:remove_from_storage).with(@model_instance)
      @engine.expects(:remove_from_remote_storage).with(@model_instance)
      @engine.remove_from_storage(@model_instance)
    end

    def test_attachment_persistts_remotely
      attachment = Attachment.new
      assert ! attachment.persists_remotely?
      attachment.is_attachment_storage_engine = @engine
      assert attachment.persists_remotely?
    end
  end
end