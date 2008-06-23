set :application, "viper.digitalblueprint.co.uk"
set :repository, "git@github.com:kevinansfield/viper.git"
 
# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/digitalb/public_html/#{application}"
 
# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
#set :branch, "website_branch"
set :repository_cache, "git_cache"
 
role :app, "viper.digitalblueprint.co.uk"
role :web, "viper.digitalblueprint.co.uk"
role :db, "viper.digitalblueprint.co.uk", :primary => true
 
set :rails_env, "production"
 
set :use_sudo, true
set :user, "digitalb"
set :jail_group, "www-data"
 
set :runner, "digitalb"
set :admin_runner, "digitalb"

# mod_rails restart
deploy.task :start, :roles => :app do
  run "touch #{current_path}/tmp/restart.txt"
end
 
deploy.task :restart, :roles => :app do
  run "touch #{current_path}/tmp/restart.txt"
end

# litespeed restart
#deploy.task :start, :roles => :app do
#  sudo "/usr/local/bin/lsws/bin/lswsctrl restart"
#end
# 
#deploy.task :restart, :roles => :app do
#  sudo "/usr/local/bin/lsws/bin/lswsctrl restart"
#end

 
task :before_symlink, :roles => :app do
  #link in shared
  run "ln -s #{deploy_to}/#{shared_dir}/avatars #{current_release}/public/avatars"
  run "ln -s #{deploy_to}/#{shared_dir}/index #{current_release}/public/index"
  #link in config
  run "cp #{deploy_to}/#{shared_dir}/system/database.yml #{current_release}/config/database.yml"
  run "cp #{deploy_to}/#{shared_dir}/system/environment.rb #{current_release}/config/environment.rb"
  run "cp #{deploy_to}/#{shared_dir}/system/production.rb #{current_release}/config/environments/production.rb"
  run "cp #{deploy_to}/#{shared_dir}/system/constants.rb #{current_release}/config/initializers/constants.rb"
  #process theme cache
  run "cd #{current_release}; rake theme_create_cache"
end
 
task :after_update_code, :roles => :app do
  sudo "chmod a+x #{release_path}/script/process/*"
end