require File.expand_path(File.join(File.dirname(__FILE__), '../test_helper'))

require "#{RAILS_ROOT}/vendor/plugins/backgroundrb/backgroundrb.rb"
require 'is_attachment_reprocess_worker'
require 'drb'

class IsAttachmentReprocessWorkerTest < Test::Unit::TestCase
  def setup
    @worker = IsAttachmentReprocessWorker.new("321")
  end

  def test_processes_versions_and_cleans_up
    attachment = mock(:reprocess_attachment_without_backgroundrb => true, :backgroundrb_job_key => "321")
    Attachment.expects(:find).with(1).returns(attachment)
    Attachment.expects(:update_all).with(['backgroundrb_job_key = ?', nil], ['id = ?', 1])
    MiddleMan.expects(:delete_worker).with("321")
    MiddleMan.expects(:new_worker).never
    @worker.do_work(:id => 1, :class => 'Attachment')
  end
end