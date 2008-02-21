# BackgrounDRb Worker to reprocess attachments.
class IsAttachmentReprocessWorker < BackgrounDRb::Rails
  # Reprocess and attactment - and sets it's backgroundrb_job_key to nil when it's done.
  # Expects args to be a hash - with values for the :class and :id of the Model Object to reprocess.
  def do_work(args)
    attachment_class = eval("#{args[:class]}")
    attachment_id = args[:id]
    attachment_to_process = attachment_class.find(attachment_id)
    attachment_to_process.reprocess_attachment_without_backgroundrb
    key = attachment_to_process.backgroundrb_job_key
    attachment_class.update_all(['backgroundrb_job_key = ?', nil], ['id = ?', attachment_id])
    MiddleMan.delete_worker(key)
  end
end