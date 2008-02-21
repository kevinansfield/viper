require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))
module PeelMeAGrape::IsAttachment::Storage
  begin
    require 'aws/s3'
    class S3Test < Test::Unit::TestCase
      def setup
        AWS::S3::Base.stubs(:establish_connection!)
        @engine = S3.new(Attachment)
        @config = S3Config.load(File.join(Test::Unit::TestCase.fixture_path, "amazon_s3.yml"))
        @engine.config = @config
        @attachment = Attachment.new
        @attachment.is_attachment_storage_engine = @engine
        @attachment.stubs(:filename).returns("my_file.jpg")
        @attachment.stubs(:id).returns(12)
      end

      def test_is_a_remote_base
        assert @engine.is_a?(RemoteBase)
      end

      def test_on_init_loads_config_and_estableishes_connection
        @engine.expects(:load_config)
        @engine.expects(:establish_connection)
        @engine.on_init
      end

      def test_remove_from_remote_storage
        @engine.stubs(:bucket_name).returns("test_bucket_name")
        AWS::S3::S3Object.expects(:delete).with("attachments/12/my_file.jpg",'test_bucket_name')
        @engine.remove_from_remote_storage(@attachment)
      end

      def test_public_path
        assert_equal "http://s3.amazonaws.com/test_bucket_name/attachments/12/my_file.jpg", @attachment.public_path
        assert_equal "http://s3.amazonaws.com/test_bucket_name/attachments/12/my_file_thumb.jpg", @attachment.public_path(:thumb)
      end

      def test_file_data
        AWS::S3::S3Object.expects(:value).with("attachments/12/my_file.jpg",'test_bucket_name')
        @engine.file_data(@attachment)
      end

      def test_persist_to_remote_storage
        @attachment.expects(:temp_data).returns("data")
        @attachment.expects(:content_type).returns("text/plain")
        AWS::S3::S3Object.expects(:store).with("attachments/12/my_file.jpg","data", 'test_bucket_name', :content_type => 'text/plain', :access => :public_read)
        @engine.persist_to_remote_storage(@attachment)
      end

      def test_copy_to_temp_file_local_missing
        @engine.file_system_engine.expects(:full_filename).returns("/som_path/that_doesnt/exist")
        @engine.expects(:file_data).returns("file_contents")
#        @engine.expects(:write_to_temp_file).with("file_contents") # todo we are using a non tempfile temp file...
        @engine.copy_to_temp_file(@attachment)
      end

      def test_copy_to_temp_file_local_present
        @engine.file_system_engine.expects(:full_filename).returns(image_upload.path)
        @engine.file_system_engine.expects(:copy_to_temp_file).with(@attachment)
        @engine.copy_to_temp_file(@attachment)
      end
    end
  rescue LoadError
    puts "\nAWS::S3 not loaded, tests not running - gem install aws-s3\n"
  end
end