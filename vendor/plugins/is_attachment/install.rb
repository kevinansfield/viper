require 'fileutils'
config_dir = File.join(File.dirname(__FILE__), '../../../config/is_attachment')
sample_default_file_src = File.join(File.dirname(__FILE__),'install/default.rb')
sample_default_file_dest = File.join(config_dir, 'default.rb')

FileUtils.mkdir_p config_dir
FileUtils.cp sample_default_file_src, sample_default_file_dest unless File.file?(sample_default_file_dest)
puts IO.read(File.join(File.dirname(__FILE__), 'INSTALL_SUMMARY'))