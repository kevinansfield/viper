namespace :is_attachment do
  desc "Generates a migration to create is_attachment db files table - for use with :db storage engine."
  task :db_files_table_migration => :environment do
    require 'rails_generator'
    require 'rails_generator/scripts/generate'
    Rails::Generator::Scripts::Generate.new.run(["is_attachment_db_files_table"])
  end

  desc "Creates Amazon S3 Bucket Configured for environment task ran against."
  task :s3_create_bucket => :environment do
    config = PeelMeAGrape::IsAttachment::Storage::S3Config.load(RAILS_ROOT + '/config/amazon_s3.yml')
    AWS::S3::Base.establish_connection!({
          :access_key_id     => config.access_key_id,
          :secret_access_key => config.secret_access_key,
          :use_ssl           => config.use_ssl
        })
    puts "AWS::S3::Bucket.create(#{config.bucket_name})"
    AWS::S3::Bucket.create(config.bucket_name)
  end
end