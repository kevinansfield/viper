require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))
module PeelMeAGrape::IsAttachment::Storage
  begin
    require 'aws/s3'
    S3.new(Attachment); AWS::S3::Bucket.find('is_attachment_development')
    class S3RoundTripTest < Test::Unit::TestCase
      def test_with_simple_attachment
        engine = S3.new(Attachment)
        attachment = Attachment.new
        attachment.is_attachment_storage_engine = engine
        attachment.uploaded_data = image_upload
        attachment.save!
      end

      def test_with_image_versions
        engine = S3.new(AttachmentWithImageVersions)
        attachment = AttachmentWithImageVersions.new
        attachment.is_attachment_storage_engine = engine
        attachment.uploaded_data = image_upload
        attachment.save!
      end

      def test_copy_to_temp_file
        engine = S3.new(Attachment)
        attachment = Attachment.new
        attachment.is_attachment_storage_engine = engine
        attachment.filename = "rails.png"
        engine.expects(:attachment_path).returns("attachments/2/rails.png")
        temp_file = engine.copy_to_temp_file(attachment)
        assert_equal 1787, File.size(temp_file)
      end
    end
  rescue LoadError
    puts "\nS3RoundTripTest - AWS::S3 not loaded, tests not running - gem install aws-s3\n"
  rescue SocketError
    puts "\nS3RoundTripTest - AWS::S3 can't connect - perhaps you aren't connected to the internet\n"
  end
end