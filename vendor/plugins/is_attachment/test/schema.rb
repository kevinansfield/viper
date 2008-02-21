ActiveRecord::Schema.define(:version => 5) do
  create_table :attachments, :force => true do |t|
    t.column :base_version_id, :integer
    t.column :version_name,    :string
    t.column :filename,        :string, :limit => 255
    t.column :content_type,    :string, :limit => 255
    t.column :file_size,       :integer
    t.column :width,           :integer
    t.column :height,          :integer
    t.column :aspect_ratio,    :float
    t.column :type,            :string
    t.column :crop_options,    :string
    t.column :other_column,    :string
  end

  create_table :mini_magick_attachments, :force => true do |t|
    t.column :base_version_id, :integer
    t.column :version_name,    :string
    t.column :filename,        :string, :limit => 255
    t.column :content_type,    :string, :limit => 255
    t.column :file_size,       :integer
    t.column :width,           :integer
    t.column :height,          :integer
    t.column :aspect_ratio,    :float
  end

  create_table :db_backed_attachments, :force => true do |t|
    t.column :is_attachment_db_file_id,   :integer
    t.column :filename,                   :string, :limit => 255
    t.column :content_type,               :string, :limit => 255
  end

  create_table :background_rb_processed_attachments, :force => true do |t|
    t.column :base_version_id,      :integer
    t.column :version_name,         :string
    t.column :filename,             :string, :limit => 255
    t.column :content_type,         :string, :limit => 255
    t.column :file_size,            :integer
    t.column :width,                :integer
    t.column :height,               :integer
    t.column :backgroundrb_job_key, :string
  end
  
  create_table :is_attachment_db_files, :force => true do |t|
    t.column :data, :binary
  end

  create_table :minimal_attachments, :force => true do |t|
    t.column :filename, :string, :limit => 255
  end
end