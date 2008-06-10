set :application, "viper.digitalblueprint.co.uk"
set :repository,  "git@github.com:kevinansfield/viper.git"

# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "/home/digitalb/public_html/#{application}"

# If you aren't using Subversion to manage your source code, specify
# your SCM below:
set :scm, :git
# set :branch, "stable"
set :repository_cache, "git_cache"

role :app, "viper.digitalblueprint.co.uk"
role :web, "viper.digitalblueprint.co.uk"
role :db,  "viper.digitalblueprint.co.uk", :primary => true

set :rails_env, "production"

set :use_sudo, true
set :user, "digitalb"
set :jail_group, "www-data"

set :runner, nil

task :restart do
  sudo "/usr/local/lsws/bin/lswsctrl restart"
end

task :before_symlink do
  #link in shared
  sudo "ln -s #{deploy_to}/#{shared_dir}/avatars #{current_release}/public/avatars"
  sudo "ln -s #{deploy_to}/#{shared_dir}/index #{current_release}/public/index"
  #link in config
  sudo "cp #{deploy_to}/#{shared_dir}/system/database.yml #{current_release}/config/database.yml"
  sudo "cp #{deploy_to}/#{shared_dir}/system/environment.rb #{current_release}/config/environment.rb"
  sudo "cp #{deploy_to}/#{shared_dir}/system/constants.rb #{current_release}/config/initializers/constants.rb"
end

task :after_update_code do
  sudo "chmod a+x #{release_path}/script/process/*"
end