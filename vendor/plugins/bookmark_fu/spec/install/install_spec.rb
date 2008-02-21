require File.dirname(__FILE__) + '/../bookmark_fu_spec_helper'

describe "Bookmark Fu install" do
  before do
    dir = File.dirname(__FILE__)
    @images_dir = "#{dir}/../rails_root/public/images"
    config_dir = "#{RAILS_ROOT}/config"
    @config_file = "#{config_dir}/bookmark_fu.yml"

    remove_test_files
    FileUtils.mkdir_p(@images_dir)
    FileUtils.mkdir_p(config_dir)

    load("#{dir}/../../install.rb")
  end

  after do
    dir = File.dirname(__FILE__)
    remove_test_files
  end

  it "adds yaml file with all of the bookmarks into the config directory" do
    BookmarkFu::Configuration.all_services.should_not be_empty
    File.read(@config_file).should == BookmarkFu::Configuration.to_yaml
  end

  it "copies the bookmarks to the social bookmarking image directory" do
    File.exists?("#{@images_dir}/social_bookmarking").should == true
    File.exists?("#{@images_dir}/social_bookmarking/digg.png").should == true
  end

  def remove_test_files
    system("rm -rf #{@images_dir}/social_bookmarking") || raise("Failed to clean up all images")
    system("rm -f #{@config_file}") || raise("Failed to clean up bookmark_fu.yml")
  end
end
