$:.unshift(File.dirname(__FILE__) + '/../lib')

ENV['RAILS_ENV'] = 'test'

require 'test/unit'
require File.expand_path(File.join(File.dirname(__FILE__), '../../../../config/environment.rb'))
require 'active_record/fixtures'
require 'action_controller/test_process'
require 'mocha'

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['mysql'])

load(File.dirname(__FILE__) + "/schema.rb") unless (ActiveRecord::Base.connection.select_one("SELECT version FROM schema_info") || {"version" => 0})["version"].to_i.eql?(5)

Test::Unit::TestCase.fixture_path = File.dirname(__FILE__) + "/fixtures"
$LOAD_PATH.unshift(Test::Unit::TestCase.fixture_path)

PeelMeAGrape::IsAttachment.file_storage_base_path = File.join(File.dirname(__FILE__), 'temp_base_dir')

require File.join(File.dirname(__FILE__), 'fixtures/attachment_classes')

class Test::Unit::TestCase #:nodoc:
  include ActionController::TestProcess

  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  def teardown
    FileUtils.rm_rf test_file_storage_base_path
    PeelMeAGrape::IsAttachment.file_storage_base_path = File.join(File.dirname(__FILE__), 'temp_base_dir')
  end
  
  def text_upload
    fixture_file_upload('/files/simple.txt', 'text/plain')
  end

  def image_upload(file_name = "rails.png")
    fixture_file_upload("/files/#{file_name}", 'image/png')
  end

  def with_mock_img(attachment, &block_with_mock)
    attachment.class.class_eval do
      attr_accessor :mock_img
    end
    attachment.mock_img = stub(:format => 'PNG', :write => true, :columns => 50, :rows => 50, :mime_type => 'image/png')
    attachment.instance_eval do
      def with_image(&block)
        block.call(mock_img)
      end
    end
    block_with_mock.call(attachment.mock_img)
  end

  def assert_file?(path)
    assert File.file?(path), "Expected file at path: #{path}"
  end

  def assert_not_file?(path)
    assert !File.file?(path), "Expected NO file at path: #{path}"
  end

  def assert_directory?(path)
    assert File.directory?(path), "Expected directory at path: #{path}"
  end

  def assert_not_directory?(path)
    assert !File.directory?(path), "Expected NO directory at path: #{path}"
  end

  def assert_creates(*models, &block)
    assert_changes_record_count_by(1, *models, &block)
  end

  def assert_destroys(*models, &block)
    assert_changes_record_count_by(-1, *models, &block)
  end

  def assert_creates_none(*models, &block)
    assert_changes_record_count_by(0, *models, &block)
  end

  def assert_changes_record_count_by(delta, *models)
    initials = []
    models.each {|model|
      model_class = model.to_s.classify
      initials << [model_class, eval("#{model_class}.count")]
    }
    yield
    initials.each {|pair|
      model = assigns(pair[0].underscore.to_sym) rescue nil
      message = model.errors.full_messages.join(", ") if model
      assert_equal pair[1] + delta, eval("#{pair[0]}.count"), "Record Count For #{pair[0]} (#{message})"
    }
    latest_models = []
    if delta>0
      initials.each {|pair|
        latest_models << eval("#{pair[0]}.find(:first, :order=>'id desc')")
      }
    end
    latest_models.size.eql?(1) ? latest_models[0] : latest_models
  end

  def assert_validation(field, message, *values)
    __model_check__
    values.each do |value|
      o = __setup_model__(field, value)
      if o.valid?
        assert_block { true }
      else
        messages = [o.errors[field]].flatten
        assert_block("unexpected invalid field <#{o.class}##{field}>, value: <#{value.inspect}>, errors: <#{o.errors[field].inspect}>.") { false }
      end
    end
  end
  alias_method :assert_valid, :assert_validation

  def assert_invalidation(field, message, *values)
    __model_check__
    values.each do |value|
      o = __setup_model__(field, value)
      if o.valid?
        assert_block("field <#{o.class}##{field}> should be invalid for value <#{value.inspect}> with message <#{message.inspect}>") { false }
      else
        messages = [o.errors[field]].flatten
        assert_block("field <#{o.class}##{field}> with value <#{value.inspect}> expected validation error <#{message.inspect}>, but got errors <#{messages.inspect}>") { messages.include?(message) }
      end
    end
  end
  alias_method :assert_invalid, :assert_invalidation

  def __model_check__
    raise "@model must be assigned in order to use validation assertions" if @model.nil?

    o = @model.dup
    raise "@model must be valid before calling a validation assertion, instead @model contained the following errors #{o.errors.instance_variable_get('@errors').inspect}" unless o.valid?
  end

  def __setup_model__(field, value)
    o = @model.dup
    attributes = o.instance_variable_get('@attributes')
    o.instance_variable_set('@attributes', attributes.dup)
    o.send("#{field}=", value)
    o
  end
  def assert_raises_with_message_check(error, message=nil, &block)
    raised = assert_raises_without_message_check(error, &block)
    assert_equal message, raised.message unless message.nil?
    return raised
  end
  alias_method_chain :assert_raises, :message_check

  protected
    def test_file_storage_base_path
      File.join(File.dirname(__FILE__), 'temp_base_dir')
    end
  
    def fixture_file_string_io_upload(path,content_type)
      file = fixture_file_upload(path)
      string_io = StringIO.new(file.read)
      (class << string_io; self; end).class_eval do
        define_method(:original_filename) {file.original_filename}
        define_method(:content_type) {file.content_type}
      end
      return string_io
    end

    def assert_created(num = 1)
      assert_difference @attachment.class, :count, num do
        yield
      end
    end

    def assert_difference(object, method = nil, difference = 1)
      initial_value = object.send(method)
      yield
      assert_equal initial_value + difference, object.send(method)
    end
end