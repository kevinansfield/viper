# BackgrounDRb Worker to process attachments
class IsAttachmentProcessBaseWorker < BackgrounDRb::Rails
  # Process and attactment - and sets it's backgroundrb_job_key to nil when it's done.
  # Expects args to be a hash - with values for the :class and :id of the Model Object to process.
  def do_work(args)
    attachment_class = eval("#{args[:class]}")
    attachment_id = args[:id]
    attachment_to_process = attachment_class.find(attachment_id)
    attachment_to_process.upload_to_process = !args[:temp_path].nil?
    attachment_to_process.temp_path = args[:temp_path]
    attachment_to_process.process_base_version_without_backgroundrb
    key = attachment_to_process.backgroundrb_job_key
    attachment_class.update_all(['backgroundrb_job_key = ?', nil], ['id = ?', attachment_id])
    MiddleMan.delete_worker(key)
  end
end