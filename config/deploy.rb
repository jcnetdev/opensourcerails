# ------------
# APP SPECIFIC SETTINGS
# ------------
set :application, "opensrcrails"
set :repository, "git@github.com:jcnetdev/opensourcerails.git"
set :server_name, "www.opensourcerails.com"

set :scm, "git"

# Set the system username for deployment
set :user, "deploy"
set :runner, "deploy"

# ------------
# REUSABLE CAPISTRANO TASKS
# ------------
role :app, server_name
role :web, server_name
role :db,  server_name, :primary => true

set :deploy_to, "/var/www/production/#{application}"
set :nginx_conf, "/var/www/nginx"

set :use_sudo, true
ssh_options[:paranoid] = false

namespace :deploy do
  desc "stop mongrel cluster"
  task :stop do
    run "cd #{current_path};mongrel_rails cluster::stop"
  end
  
  desc "start mongrel cluster"
  task :start do
    run "cd #{current_path};mongrel_rails cluster::start"
  end
  
  desc "restart app"
  task :restart do
    run "cd #{current_path};mongrel_rails cluster::restart"
  end

  desc "restart mongrel cluster"
  task :restart_mongrel do
    run "cd #{current_path};mongrel_rails cluster::restart"
  end

  desc "restart nginx cluster"
  task :restart_nginx do
    sudo "/etc/init.d/nginx stop"
    sudo "/etc/init.d/nginx start"
  end

  desc "start nginx cluster"
  task :start_nginx do
    sudo "/etc/init.d/nginx start"
  end

  desc "stop nginx cluster"
  task :stop_nginx do
    sudo "/etc/init.d/nginx stop"
  end
  
  task :merge_statics do
    sudo "date"
    run "cd #{current_path} && sudo ./script/merge_javascript_css"
  end
  
end

# SET UP EVENTS
before "deploy:restart", "admin:migrate"
after  "deploy", "live:send_request"

after "deploy:setup", "init:database_yml"
after "deploy:setup", "init:setup_proxy"
after "deploy:setup", "init:create_database"
after "deploy:update_code", "localize:copy_shared_configurations"
after "deploy:update_code", "localize:copy_nginx_conf"
after "deploy:update_code", "localize:upload_folders"
after "deploy:update_code", "localize:install_gems"

namespace :localize do
  desc "copy shared configurations to current"
  task :copy_shared_configurations, :roles => [:app] do
    %w[mongrel_cluster.yml database.yml amazon_s3.yml].each do |f|
      run "ln -nsf #{shared_path}/config/#{f} #{release_path}/config/#{f}"
    end
  end
    
  desc "copy nginx configuration over"
  task :copy_nginx_conf, :roles => [:app] do
    run "mkdir -p #{nginx_conf}"
    run "ln -nsf #{shared_path}/config/nginx.conf #{nginx_conf}/#{application}-nginx.conf"
  end 
  
  desc "installs / upgrades gem dependencies "
  task :install_gems, :roles => [:app] do
    sudo "date" # fuck you capistrano
    run "cd #{release_path} && sudo rake RAILS_ENV=production gems:install"
  end
  
  task :upload_folders, :roles => [:app] do
    # create symlink for screenshots
    run "mkdir -p #{deploy_to}/shared/screenshots"
    run "ln -s #{deploy_to}/shared/screenshots #{release_path}/public/screenshots"
    
    # create symlink for downloads
    run "mkdir -p #{deploy_to}/shared/downloads"
    run "ln -s #{deploy_to}/shared/downloads #{release_path}/public/downloads"
  end
  
end

namespace :init do
  desc "create mysql db"
  task :create_database do
    #create the database on setup
    set :db_user, Capistrano::CLI.ui.ask("database user: ") unless defined?(:db_user)
    set :db_pass, Capistrano::CLI.password_prompt("database password: ") unless defined?(:db_pass)
    run "echo \"CREATE DATABASE #{application}_production\" | mysql -u #{db_user} --password=#{db_pass}"
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
  
  desc "Setups up Web Proxy (nginx and mongrel)"
  task :setup_proxy do
    set :server_domains, Capistrano::CLI.ui.ask("your domain(s): ")
    set :mongrel_port, Capistrano::CLI.ui.ask("mongrel port: ").to_i
    set :mongrel_count, Capistrano::CLI.ui.ask("mongrel count: ").to_i
    
    # BUILD MONGREL CONFIG
    mongrel_cluster_configuration = %(
--- 
user: deploy
group: deploy
cwd: #{current_path}
log_file: #{current_path}/log/mongrel.log
environment: production
address: 127.0.0.1
pid_file: #{current_path}/tmp/pids/mongrel.pid
port: "#{mongrel_port}"
servers: #{mongrel_count}
)
    run "mkdir -p #{shared_path}/config"
    put mongrel_cluster_configuration, "#{shared_path}/config/mongrel_cluster.yml"
    
    servers = ""
    mongrel_count.times do |i|
      servers << "server 127.0.0.1:#{mongrel_port+i};\n"
    end
    
    # BUILD NGINX CONFIG
    nginx_configuration = %%
upstream #{application}_cluster {
  #{servers}
}

server {
  listen 80;
  client_max_body_size 100M;
  server_name #{server_domains};
  root /var/www/production/#{application}/current/public;
  access_log /var/log/nginx/#{application}.access.log main;

  if (-f $document_root/system/maintenance.html) {
    rewrite  ^(.*)$  /system/maintenance.html last;
    break;
  }

  location / {
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header Host $http_host;
    proxy_redirect false;
    proxy_max_temp_file_size 0;
    if (-f $request_filename) {
      break;
    }
    if (-f $request_filename/index.html) {
      rewrite (.*) $1/index.html break;
    }
    if (-f $request_filename.html) {
      rewrite (.*) $1.html break;
    }
    if (!-f $request_filename) {
      proxy_pass http://#{application}_cluster;
      break;
    }
  }

  error_page 500 502 503 504 /500.html;
  location = /500.html {
    root /var/www/production/#{application}/current/public;
  }
}    
%
    put nginx_configuration, "#{shared_path}/config/nginx.conf"
  end
end

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

namespace :admin do    
  task :set_schema_info do    
    new_schema_version = Capistrano::CLI.ui.ask "New Schema Info Version: "
    run "cd #{current_path} && ./script/runner --environment=production 'ActiveRecord::Base.connection.execute(\"UPDATE schema_info SET version=#{new_schema_version}\")'"
  end
  
  task :migrate do
    run "cd #{current_path} && RAILS_ENV=production rake db:migrate"
  end
  
  task :remote_rake do
    rake_command = Capistrano::CLI.ui.ask "Rake Command to run: "
    run "cd #{current_path} && sudo RAILS_ENV=production rake #{rake_command}"
  end
end