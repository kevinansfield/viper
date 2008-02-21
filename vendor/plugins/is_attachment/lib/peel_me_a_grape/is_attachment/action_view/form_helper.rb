module PeelMeAGrape::IsAttachment::ActionView::FormHelper 
  # Renders a file field for an 'is_attachment' model - along with a #is_attachment_hidden_file_field (to keep uploaded files across form redisplays)
  def is_attachment_file_field(object_name, options = {})
    attachment_model = options.delete(:object)
    result = is_attachment_hidden_file_field(object_name, options = {:object => attachment_model})
    result << ActionView::Helpers::InstanceTag.new(object_name, "uploaded_data", self, nil, attachment_model).to_input_field_tag("file", options)
    result << "<span class=\"is_attachment_uploaded_file\">#{attachment_model.nil? ? "" : attachment_model.filename}</span>"
  end

  # Renders a hidden field for an 'is_attachment' model to keep uploaded files across form redisplays
  def is_attachment_hidden_file_field(object_name, options = {})
    ActionView::Helpers::InstanceTag.new(object_name, "already_uploaded_data", self, nil, options.delete(:object)).to_input_field_tag("hidden", {})
  end
end