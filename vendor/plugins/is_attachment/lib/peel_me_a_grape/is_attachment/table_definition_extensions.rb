module PeelMeAGrape::IsAttachment::TableDefinitionExtensions
  # todo rdocs...
  def attachment_columns(options = {})
    options.assert_valid_keys(:versions, :metadata)
    column(:string, :filename)
    if options[:versions]
      column(:string, :version_name)
      column(:integer, :base_version_id)
    end
    if options[:metadata]
      column(:string, :content_type)
      column(:integer, :width, :height, :file_size)
    end
  end

  # todo all kinds of examples... 
# t.attachment_columns(:versions => true, :metadata => true)

#  t.column :base_version_id, :integer
#  t.column :version_name,    :string
#  t.column :filename,        :string, :limit => 255
#  t.column :content_type,    :string, :limit => 255
#  t.column :file_size,       :integer
#  t.column :width,           :integer
#  t.column :height,          :integer

end