set :application, "yortz.it"
# set :domain, "yortz.it"
set :repository, "slicehost:/home/yortz/git/repos/yortz.git"

set :use_sudo, true
set :user, 'yortz'
set :runner, 'yortz'
set :keep_releases, 1 

set :deploy_to, "/var/jekyll/#{application}"
set :current_deploy_dir, "#{deploy_to}/current"
set :deploy_via, :remote_cache
set :tmp_dir, "#{deploy_to}/tmp"

# set :deploy_to, "/var/www/#{application}"
set :branch, "master"

ssh_options[:paranoid] = false
default_run_options[:pty] = true
ssh_options[:keys] = %w(/Users/yortz/.ssh/id_rsa)
ssh_options[:port] = 12345
 
server "12.34.5.67", :app, :web, :db, :primary => true
 
set :scm, :git
set :deploy_via, :remote_cache
 
namespace :deploy do
  
  desc "link to www"
  task :ls_app do
  run "cd /var/www"
  sudo "ln -s #{deploy_to}/current/_site /var/www/#{application}"
  end
  
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
after "deploy:symlink", "deploy:ls_app"
# after "apache:ls_app" , "apache:config_vhost"

namespace :apache do

  desc "Configure VHost"
  task :config_vhost do
    vhost_config =<<-EOF
     <VirtualHost *:80>
      ServerName #{application}
      DocumentRoot #{deploy_to}/current/_site
      CustomLog #{shared_path}/log/access.log common
      ErrorLog #{shared_path}/log/error.log
      <Directory "#{deploy_to}/current/_site">
      Options FollowSymLinks
      AllowOverride None
      Order allow,deny
      Allow from all 
      </Directory>
      </VirtualHost>
    EOF
    put vhost_config, "vhost_config"
    sudo "mv vhost_config /etc/apache2/sites-available/#{application}"
    sudo "a2ensite #{application}"
  end
  
  desc "Enable Site"
  task :enable_vhost do
  sudo "a2ensite #{application}"
end

desc "Reload Apache"
task :reload do
  sudo "/etc/init.d/apache2 reload"
end

desc "Disable Site"
task :disable_vhost do
sudo "a2dissite #{custom_server_address}"
end

desc " Generate .htpassword"
task :gen_htpassword do
  htpassword =<<-EOF
yortz:mysecretpass
  EOF
  put htpassword, ".htpassword"
  sudo "mv .htpassword /var/jekyll/yortz.it"
end

desc "Generate .htaccess to protect folder for testing"
task :gen_htaccess do
  htaccess =<<-EOF
AuthName "Restricted Area" 
AuthType Basic 
AuthUserFile /var/jekyll/yortz.it/.htpasswd 
AuthGroupFile /dev/null 
require valid-user  
  EOF
  put htaccess, ".htaccess"
  sudo "mv .htaccess #{current_path}/_site"
end

end