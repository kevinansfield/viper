require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))
module PeelMeAGrape::IsAttachment::Storage
  class S3ConfigTest < Test::Unit::TestCase
    def test_load_config
      config_file = File.join(Test::Unit::TestCase.fixture_path, "amazon_s3.yml")
      config = S3Config.load(config_file)
      assert_equal 'test_bucket_name', config.bucket_name
      assert_equal 'ABC123456', config.access_key_id
      assert_equal 'ABC654321', config.secret_access_key
      assert config.use_ssl
    end

    def test_raises_if_missing_required_values
      message = "Invalid S3 Config - required keys are (:access_key_id, :secret_access_key and :bucket_name) - :use_ssl is optional. Check you have correctly configured /config/amazon_s3.yml for #{RAILS_ENV} environment"
      assert_raises(ArgumentError, message) {S3Config.new(nil)}
      assert_raises(ArgumentError, message) {S3Config.new({:bucket_name => 'my_bucket'})}
      assert_raises(ArgumentError) {S3Config.new({:bad_option => 'value'})}
    end
  end
end