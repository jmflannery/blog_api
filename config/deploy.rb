# config valid only for current version of Capistrano
lock '3.6.1'

set :application, 'blog_api'
set :repo_url, 'git@github.com:jmflannery/blog_api.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, '/var/www/my_app_name'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
append :linked_files, 'config/database.yml', 'config/secrets.yml'

# Default value for linked_dirs is []
append :linked_dirs, 'log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'public/system'

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

# files will be copied from source to the dest
set :shared_files, ['config/database.yml.erb', 'config/secrets.yml.erb']

namespace :deploy do

  after 'publishing', 'restart'

  desc "Initial cold deploy"
  task :cold do
    on roles(:app) do
      # Don't check if linked files exist, instead copy them to shared dir
      Rake::Task["deploy:check:linked_files"].clear
      before 'deploy:symlink:shared', 'deploy:setup_config'
      invoke 'deploy'
    end
  end

  desc "Copy config files into shared"
  task :setup_config do
    require 'erb'
    on roles(:app) do
      within release_path do

        # Copy files shared between releases to the shared directory
        shared_files = fetch(:shared_files, [])
        shared_files.each do |shared_file|
          execute :mkdir, '-p', "#{shared_path}/#{Pathname(shared_file).dirname}"

          # Process the files with ERB and local binding
          result = process_erb(shared_file)
          destination = shared_file.sub('.erb', '')
          upload! result, "#{shared_path}/#{destination}"
        end
      end
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end
end

def process_erb(path)
  StringIO.new(ERB.new(File.read(path)).result(binding))
end
