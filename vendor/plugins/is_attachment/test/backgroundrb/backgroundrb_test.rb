require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))
module PeelMeAGrape::IsAttachment
  class BackgroundrbTest < Test::Unit::TestCase
    def setup
      @attachment = BackgroundRbProcessedAttachments.new
      @attachment.uploaded_data = image_upload
      @attachment.id = 1
    end

    def test_included_when_configured
      assert @attachment.respond_to?(:process_base_version_with_backgroundrb)
      assert @attachment.respond_to?(:process_base_version_without_backgroundrb)
    end

    def test_only_included_when_configured
      attachment = Attachment.new
      assert !attachment.respond_to?(:process_base_version_with_backgroundrb)
      assert !attachment.respond_to?(:process_base_version_without_backgroundrb)
    end

    def test_raises_if_no_column_for_job_key
      model = mock(:column_names => [])
      assert_raises(ConfigurationConflictError, "To use backgroundrb your model must include a 'backgroundrb_job_key' column.") do
        Backgroundrb.included(model)
      end
    end

    def test_raises_if_backgroundrb_not_installed
      Object.expects(:const_defined?).with(:MiddleMan).returns(false)
      model = mock()
      assert_raises(ConfigurationConflictError, "backgroundrb not installed") do
        Backgroundrb.included(model)
      end
    end

    def test_process_base_version_with_backgroundrb_creates_job
      @attachment.expects(:image_version_options).returns({:thumb => 50})
      MiddleMan.expects(:new_worker).with(:class => :is_attachment_process_base_worker, :args => {:id => @attachment.id, :class => @attachment.class.to_s, :temp_path => @attachment.temp_path}).returns("12345")
      @attachment.expects(:process_base_version_without_backgroundrb).never
      @attachment.expects(:update_backgroundrb_job_key).with("12345")
      @attachment.process_base_version_with_backgroundrb
    end

    def test_process_base_version_with_backgroundrb_no_job_for_non_base_version
      @attachment.expects(:image_version_options).never
      @attachment.expects(:is_base_version?).returns(false).at_least_once
      @attachment.expects(:process_base_version_without_backgroundrb)
      MiddleMan.expects(:new_worker).never
      @attachment.process_base_version_with_backgroundrb
    end

    def test_job_created_for_attachment_with_no_image_versions_when_persisted_remotely
      MiddleMan.expects(:new_worker).with(:class => :is_attachment_process_base_worker, :args => {:id => @attachment.id, :class => @attachment.class.to_s, :temp_path => @attachment.temp_path}).returns("12345")
      @attachment.expects(:update_backgroundrb_job_key).with("12345")
      @attachment.expects(:image_version_options).returns({})
      @attachment.expects(:persisted_remotely?).returns(true)
      @attachment.expects(:process_base_version_without_backgroundrb).never
      @attachment.process_base_version_with_backgroundrb
    end

    def test_when_no_image_versions_no_job_created
      MiddleMan.expects(:new_worker).never
      @attachment.expects(:image_version_options).returns({})
      @attachment.expects(:process_base_version_without_backgroundrb)
      @attachment.process_base_version_with_backgroundrb
    end

    def test_method_to_check_if_finished_on_base_version
      @attachment.expects(:backgroundrb_job_key).returns(nil)
      @attachment.expects(:has_all_versions?).returns(false)
      assert !@attachment.backgroundrb_finished?
      @attachment.expects(:backgroundrb_job_key).returns(nil)
      @attachment.expects(:has_all_versions?).returns(true)
      assert @attachment.backgroundrb_finished?
      @attachment.expects(:backgroundrb_job_key).returns("12242")
      @attachment.expects(:has_all_versions?).never
      assert !@attachment.backgroundrb_finished?
      @attachment.expects(:backgroundrb_job_key).returns("12242")
      assert !@attachment.backgroundrb_finished?
    end

    def test_resorts_to_in_process_when_middle_man_fails
      @attachment.expects(:process_base_version_without_backgroundrb)
      MiddleMan.expects(:new_worker).with(:class => :is_attachment_process_base_worker, :args => {:id => @attachment.id, :class => @attachment.class.to_s, :temp_path => @attachment.temp_path}).raises(StandardError.new)
      RAILS_DEFAULT_LOGGER.expects(:error).with("Problem Creating BackgroundRb Worker - Resorting to processing in process.")
      @attachment.expects(:update_backgroundrb_job_key).never
      @attachment.process_base_version_with_backgroundrb
    end

    def test_reprocess_attachment_creates_one_job
      @attachment.expects(:is_base_version?).never
      @attachment.expects(:reprocess_attachment_without_backgroundrb).never
      MiddleMan.expects(:new_worker).with(:class => :is_attachment_reprocess_worker, :args => {:id => @attachment.id, :class => @attachment.class.to_s}).times(1).returns("12345")
      @attachment.expects(:update_backgroundrb_job_key).with("12345")
      @attachment.reprocess_attachment_with_backgroundrb
    end

    def test_resorts_to_reprocess_in_process_when_middle_man_raises
      @attachment.expects(:reprocess_attachment_without_backgroundrb) # fall back to in process
      MiddleMan.expects(:new_worker).with(:class => :is_attachment_reprocess_worker, :args => {:id => @attachment.id, :class => @attachment.class.to_s}).raises(StandardError.new)
      RAILS_DEFAULT_LOGGER.expects(:error).with("Problem Creating BackgroundRb Worker - Resorting to processing in process.")
      @attachment.expects(:update_backgroundrb_job_key).never
      @attachment.reprocess_attachment_with_backgroundrb
    end

    def test_running_in_backgroundrb
      @attachment.expects(:backgroundrb_job_key).returns("123")
      assert @attachment.running_in_backgrounrb?
      @attachment.expects(:backgroundrb_job_key).returns(nil)
      assert !@attachment.running_in_backgrounrb?
    end

    def test_doesnt_create_jobs_for_process_when_already_in_bgdrb
      @attachment.expects(:running_in_backgrounrb?).returns(true)
      @attachment.expects(:reprocess_attachment_without_backgroundrb)
      MiddleMan.expects(:new_worker).never
      @attachment.reprocess_attachment_with_backgroundrb
    end

    def test_doesnt_create_jobs_for_reprocess_when_already_in_bgdrb
      @attachment.expects(:running_in_backgrounrb?).returns(true)
      @attachment.expects(:process_base_version_without_backgroundrb)
      MiddleMan.expects(:new_worker).never
      @attachment.process_base_version_with_backgroundrb
    end
  end
end