namespace :js_image_cropper do
  require 'fileutils'
  desc 'Copy Cropper js/css to javascripts directory'
  task :install do
    javascripts_dir = File.join(File.dirname(__FILE__), '../../../../public/javascripts')
    ['cropper.js', 'cropper.uncompressed.js', 'cropper.css'].each do |file|
      FileUtils.cp File.join(File.dirname(__FILE__),'../install', file), File.join(javascripts_dir, file)
    end
  end
end