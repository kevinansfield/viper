require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))

require "#{RAILS_ROOT}/vendor/plugins/backgroundrb/backgroundrb.rb"
require 'is_attachment_process_base_worker'
require 'drb'

class IsAttachmentProcessBaseWorkerTest < Test::Unit::TestCase
  def setup
    @worker = IsAttachmentProcessBaseWorker.new("123")
  end

  def test_processes_versions_and_cleans_up
    attachment = mock(:process_base_version_without_backgroundrb => true, :backgroundrb_job_key => "123")
    Attachment.expects(:find).with(1).returns(attachment)
    attachment.expects(:temp_path=).with('/temp/path/image.jpg')
    attachment.expects(:upload_to_process=).with(true)
    Attachment.expects(:update_all).with(['backgroundrb_job_key = ?', nil], ['id = ?', 1])
    MiddleMan.expects(:delete_worker).with("123")
    @worker.do_work(:id => 1, :class => 'Attachment', :temp_path => '/temp/path/image.jpg')
  end
end