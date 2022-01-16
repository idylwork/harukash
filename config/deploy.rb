# config valid for current version and patch releases of Capistrano
lock "~> 3.16.0"

set :application, "harukash"
set :repo_url, "git@gitlab.com:yoshinaga/harukash.com.git"
#set :application, ENV['DEPLOY_APP']
#set :repo_url, ENV['DEPLOY_REPO_URL']
set :branch, "master"
set :log_level, :debug

set :linked_dirs, fetch(:linked_dirs, []).push("log", "public/images")
set :linked_files, fetch(:linked_files, []).push("config/master.key")
set :linked_files, fetch(:linked_files, []).push(".env")
set :keep_releases, 3
set :use_sudo, false
set :ssh_options, keepalive: true

# sudo mkdir
namespace :deploy do
  Rake::Task["deploy:check:directories"].clear
  Rake::Task["deploy:check:linked_dirs"].clear

  namespace :check do
    desc "(overwrite) Check shared and release directories exist"
    task :directories do
      on release_roles :all do
        execute :sudo, :mkdir, "-pv", shared_path, releases_path
      end
    end

    desc "Create Database"
    task :db_create do
      on roles(:db) do |_host|
        with rails_env: fetch(:rails_env) do
          within current_path do
            execute :bundle, :exec, :rake, "db:create"
          end
        end
      end
    end

    # シンボリックリンク作成
    task :linked_dirs do
      next unless any? :linked_dirs
      on release_roles :all do
        execute :sudo, :mkdir, "-pv", linked_dirs(shared_path)
      end
    end
  end

  desc "Restart application"
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # invoke 'unicorn:restart'
      execute("sudo /etc/rc.d/init.d/unicorn_harukash restart")
      #execute("sudo #{ENV['UNICORN_COMMAND']} restart")
    end
  end
  after :publishing, :restart
end

set :pty, true

# yarn:install
set :yarn_flags, "--prefer-offline --production"
set :yarn_roles, :app

# webpacker build
namespace :webpack do
  after "yarn:install", "webpack:build"
  task :build do
    on roles(:app) do
      execute "cd #{release_path} && #{fetch :yarn_bin} run build:production"
    end
  end
end

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml"

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public/system"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV["USER"]
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
