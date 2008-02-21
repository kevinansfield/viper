class IsAttachmentDbFilesTableGenerator < Rails::Generator::NamedBase
  def initialize(runtime_args, runtime_options = {})
    runtime_args << 'add_is_attachment_db_files_table' if runtime_args.empty?
    super
  end
#
  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', :assigns => { :is_attachment_db_files_table_name => 'is_attachment_db_files' }
    end
  end
end
