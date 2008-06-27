namespace :js_image_cropper do
  require 'fileutils'
  desc 'Copy Cropper js/css to javascripts directory'
  task :install do
    cur_dir = File.dirname(__FILE__)
    public_dir = File.join(cur_dir, '../../../../public')
    ['cropper.js', 'cropper.uncompressed.js', 'cropper.css', 'marqueeHoriz.gif', 'marqueeVert.gif'].each do |file|
      FileUtils.cp File.join(cur_dir,'../install', file), File.join(public_dir, 'javascripts', file)
    end
  end
end
