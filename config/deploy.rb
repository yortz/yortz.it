set :application, "yortz.it"
# set :domain, "yortz.it"
set :repository, "slicehost:/home/yortz/git/repos/yortz.git"

set :use_sudo, true
set :user, 'yortz'
set :runner, 'yortz'
set :keep_releases, 1 

set :deploy_to, "/var/www/#{application}"

set :branch, "master"


ssh_options[:paranoid] = false
default_run_options[:pty] = true
ssh_options[:keys] = %w(/Users/yortz/.ssh/id_rsa)
ssh_options[:port] = 39669
 
server "67.23.0.81", :app, :web, :db, :primary => true
 
set :scm, :git
set :deploy_via, :remote_cache
 
namespace :deploy do
  
  desc "Set application directory user and permission"
   task :set_app_dir_access, :roles => :app do
     sudo "chown #{user}:#{user} -R #{deploy_to}"
   end
  
  task :restart, :roles => :app do
  end
 
  task :start, :roles => :app do
    # nothing
  end
 
  task :stop, :roles => :app do
    # nothing
  end
  
  task :finalize_update do
    # nothing
  end
end
 
namespace :jekyll do
  desc "Generates the site on the remote server"
  task :generate_site do
    run "cd #{current_release} && rake site:generate"
  end
  
end
 
after "deploy:setup", "deploy:set_app_dir_access" 
after "deploy:update_code", "jekyll:generate_site"