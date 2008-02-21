module PeelMeAGrape::IsAttachment::ActionView::FormBuilderHelper # :nodoc:
  # see PeelMeAGrape::IsAttachment::ActionView::FormBuilder#is_attachment_file_field
  def is_attachment_file_field(options = {})
    options = {} unless options.is_a? Hash
    @template.is_attachment_file_field(@object_name, options.merge(:object => @object))
  end
end
