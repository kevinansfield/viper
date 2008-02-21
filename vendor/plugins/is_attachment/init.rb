require 'dir_empty'

ActiveRecord::Base.send(:extend, PeelMeAGrape::IsAttachment::ActMethods)
ActionView::Base.send(:include, PeelMeAGrape::IsAttachment::ActionView::FormHelper)
ActionView::Helpers::FormBuilder.send(:include, PeelMeAGrape::IsAttachment::ActionView::FormBuilderHelper)
ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, PeelMeAGrape::IsAttachment::TableDefinitionExtensions)

all_environments_config = File.join(RAILS_ROOT, 'config', 'is_attachment' , 'default')
environment_specific_config = File.join(RAILS_ROOT, 'config', 'is_attachment' , RAILS_ENV)

require all_environments_config if File.file?(all_environments_config + '.rb')
require environment_specific_config if File.file?(environment_specific_config + '.rb')

FileUtils.mkdir_p PeelMeAGrape::IsAttachment.tempfile_path