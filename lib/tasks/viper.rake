require 'fileutils'

namespace :viper do
  desc "Backup attachment_fu user/avatar associations ready for conversion to is_attachment"
  task :backup_attachment_fu_details => :environment do
    users = User.find :all
    user_avatars = []
    for user in users
      user_avatars << {:user_id => user.id, :avatar_id => user.avatar.id} unless user.avatar.nil?
    end
    
    backup_file = File.join(File.dirname(__FILE__), '../../db/attachment_fu_backup.xml')
    File.open(backup_file, 'w') do |f1|
      f1.puts user_avatars.to_xml
    end
    
    puts "attachment_fu associations backed up to db/attachment_fu_backup.xml"
  end
  
  desc "Uses attachment_fu backup file to create new is_attachment models"
  task :convert_to_is_attachment => :environment do
    backup_file = File.join(File.dirname(__FILE__), '../../db/attachment_fu_backup.xml')
    File.open(backup_file, 'r') do |f1|
      attachment_fu_xml = f1.read
    end
    
    user_avatars = Hash.from_xml(attachment_fu_xml)
    user_avatars["records"].each do |record|
      # record["user_id"] record["avatar_id"]
      
    end
  end
end