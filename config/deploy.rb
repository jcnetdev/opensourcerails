# ------------
# APP SPECIFIC SETTINGS
# ------------
set :application, "[YOUR APP NAME]"
set :server_name, "[YOUR APP DOMAIN NAME, e.g. www.opensourcerails.com]"

set :repository, "git@github.com:jcnetdev/opensourcerails.git"
set :scm, "git"
set :checkout, "export" 
set :deploy_via, :remote_cache

# set the list of config files to symlink on deployment
set :linked_files, [
                     "config/database.yml",
                     "config/app_config.yml",
                     "config/environments/production.yml",
                     "app/views/pages/about.html.haml"
                   ]

# set the list of folders to symlink on deployment
set :linked_folders, %w[public/screenshots public/downloads]
set(:app, "srcrails") unless respond_to?(:app)

load File.dirname(__FILE__)+"/sites/#{app}" 

set :base_path, "/var/www"
set :deploy_to, "/var/www/production/#{application}"
set :apache_site_folder, "/etc/apache2/sites-enabled"

set :keep_releases, 3

set :user, 'deploy'
set :runner, 'deploy'

# =============================================================================
# You shouldn't have to modify the rest of these
# =============================================================================

role :web, server_name
role :app, server_name
role :db,  server_name, :primary => true

set :use_sudo, true

# saves space by only keeping last 3 when running cleanup
set :keep_releases, 3 

ssh_options[:paranoid] = false


# ===================
# DEPLOYMENT TASKS
# ===================
namespace :deploy do

  desc "Restart Passenger" 
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt" 
    run "curl http://#{server_name} -g"
  end

  desc <<-DESC
    Deploy and run pending migrations. This will work similarly to the \
    `deploy' task, but will also run any pending migrations (via the \
    `deploy:migrate' task) prior to updating the symlink. Note that the \
    update in this case it is not atomic, and transactions are not used, \
    because migrations are not guaranteed to be reversible.
  DESC
  task :migrations do
    set :migrate_target, :latest
    update_code
    migrate
    symlink
    restart
  end
  
  desc "restart apache"
  task :restart_apache do
    sudo "/etc/init.d/apache2 stop"
    sudo "/etc/init.d/apache2 start"
  end

  desc "start apache cluster"
  task :start_apache do
    sudo "/etc/init.d/apache2 start"
  end

  desc "stop apache cluster"
  task :stop_apache do
    sudo "/etc/init.d/apache2 stop"
  end
end

before "deploy:restart", "admin:migrate"
after  "deploy", "live:send_request"


# ===================
# LOCALIZE TASKS
# ===================
after "deploy:update_code", "localize:install_gems"
after "deploy:update_code", "localize:set_permissions"
after "deploy:update_code", "localize:link_files"
after "deploy:update_code", "localize:link_folders"
after "deploy:update_code", "localize:merge_assets"

namespace :localize do
  desc "installs / upgrades gem dependencies "
  task :install_gems, :roles => [:app] do
    sudo "date"
    run "cd #{release_path} && sudo rake RAILS_ENV=production gems:install"
  end

  desc "setting proper permissions for deploy user"
  task :set_permissions do
    sudo "chown -R deploy /var/www/production/#{application}"
  end
    
  desc "create symlinks for files specified in the linked_files array"
  task :link_files, :roles => [:app] do
    if defined? :linked_files
      linked_files.each do |f|
        run "ln -nsf #{shared_path}/#{f} #{release_path}/#{f}"
      end
    end
  end
  
  desc "create symlinks for folders specified in the linked_folders array"
  task :link_folders, :roles => [:app] do
    if defined? :linked_folders
      linked_folders.each do |f|
        run "mkdir -p #{shared_path}/#{f}"
        run "ln -nsf #{shared_path}/#{f} #{release_path}/#{f}"
      end
    end
  end
  
  desc "merge asset files"
  task :merge_assets, :roles => [:app] do
    if File.exists?(File.join(File.dirname(__FILE__), "..", "script", "merge_assets"))
      sudo "date" 
      run "cd #{release_path} && sudo script/merge_assets"
    end
  end

  task :merge_current_assets, :roles => [:app] do
    if File.exists?(File.join(File.dirname(__FILE__), "..", "script", "merge_assets"))
      sudo "date" 
      run "cd #{current_path} && sudo script/merge_assets"
    end
  end


end

# ===================
# SETUP TASKS
# ===================
after "deploy:setup", "init:set_permissions"
after "deploy:setup", "init:create_vhost"
after "deploy:setup", "init:upload_linked_files"
after "deploy:setup", "init:database_yml"
after "deploy:setup", "init:create_database"
after "deploy:setup", "init:enable_site"
namespace :init do
  
  desc "setting proper permissions for deploy user"
  task :set_permissions do
    sudo "chown -R deploy /var/www/production/"
  end

  desc "create mysql db"
  task :create_database do
    #create the database on setup
    set :db_user, Capistrano::CLI.ui.ask("database user: ") unless defined?(:db_user)
    set :db_pass, Capistrano::CLI.password_prompt("database password: ") unless defined?(:db_pass)
    begin
      run "echo \"CREATE DATABASE #{application}_production\" | mysql -u #{db_user} --password=#{db_pass}"
    rescue
      puts "DATABASE #{application}_production already exists"
    end
  end
  
  desc "enable site"
  task :enable_site do 
    sudo "ln -nsf #{shared_path}/config/apache_site.conf #{apache_site_folder}/#{application}"
  end
  
  
  desc "create database.yml"
  task :database_yml do
    set :db_user, Capistrano::CLI.ui.ask("database user: ")
    set :db_pass, Capistrano::CLI.password_prompt("database password: ")
    database_configuration = %(
---
login: &login
  adapter: mysql
  database: #{application}_production
  host: localhost
  username: #{db_user}
  password: #{db_pass}

production:
  <<: *login
)
    run "mkdir -p #{shared_path}/config"
    put database_configuration, "#{shared_path}/config/database.yml"
  end
  
  desc "create vhost file"
  task :create_vhost do
    
    vhost_configuration = %(
<VirtualHost *>
  ServerName #{server_name}
  DocumentRoot /var/www/production/#{application}/current/public
</VirtualHost>
)
    run "mkdir -p #{shared_path}/config"
    put vhost_configuration, "#{shared_path}/config/apache_site.conf"
  end
  
  desc "upload link files"
  task :upload_linked_files do
    if defined? :linked_files
      linked_files.each do |f|
        local_path = File.join(File.dirname(__FILE__), "..", f)
        run "mkdir -p #{shared_path}/#{File.dirname(f)}"
        upload local_path,"#{shared_path}/#{f}"
      end
    end
  end
end

# ===================
# ADMIN TASKS
# ===================
namespace :admin do    
  task :set_schema_info do    
    new_schema_version = Capistrano::CLI.ui.ask "New Schema Info Version: "
    run "cd #{current_path} && ./script/runner --environment=production 'ActiveRecord::Base.connection.execute(\"UPDATE schema_info SET version=#{new_schema_version}\")'"
  end
  
  task :migrate do
    run "cd #{current_path} && sudo rake RAILS_ENV=production db:migrate"
  end
  
  task :remote_rake do
    rake_command = Capistrano::CLI.ui.ask "Rake Command to run: "
    run "cd #{current_path} && sudo rake RAILS_ENV=production #{rake_command}"
  end
end

# ===================
# LIVE TOOLS
# ===================
namespace :live do
  desc "send request" 
  task :send_request do
    url = "http://#{server_name}"
    puts `curl #{url} -g`
  end
    
  desc "remotely console" 
  task :console, :roles => :app do
    input = ''
    run "cd #{current_path} && ./script/console production" do |channel, stream, data|
      next if data.chomp == input.chomp || data.chomp == ''
      print data
      channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
    end
  end
  
  desc "tail production log files" 
  task :tail_logs, :roles => :app do
    run "tail -f #{shared_path}/log/production.log -n 200" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}" 
      break if stream == :err    
    end
  end

  desc "show environment variables" 
  task :env, :roles => :app do
    run "env"
  end
  
  task :show_env do
    run "env"
  end
  
  task :show_path do
    run "echo #{current_path}"
  end
  
  desc "remotely console" 
  task :console, :roles => :app do
    input = ''
    run "cd #{current_path} && ./script/console production" do |channel, stream, data|
      next if data.chomp == input.chomp || data.chomp == ''
      print data
      channel.send_data(input = $stdin.gets) if data =~ /^(>|\?)>/
    end
  end
  
  desc "tail production log files" 
  task :tail_logs, :roles => :app do
    run "tail -f #{shared_path}/log/production.log -n 200" do |channel, stream, data|
      puts  # for an extra line break before the host name
      puts "#{channel[:host]}: #{data}" 
      break if stream == :err    
    end
  end
end