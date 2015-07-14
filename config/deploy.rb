## Generated with 'brightbox' on 2012-03-13 16:12:26 +0000
gem 'brightbox', '>=2.3.9'
require 'capistrano/ext/multistage'
require 'brightbox/recipes'
require 'brightbox/passenger'

set :default_stage, 'staging'
ssh_options[:forward_agent] = true

set :application, "cites_dashboard"
set :user, "rails"
set :repository, "git@github.com:unepwcmc/cites_dashboards"

set :scm, :git
set :scm_username, "unepwcmc-read"

set :bundle_disable, true

# Target directory for the application on the web and app servers.
set(:deploy_to) { File.join("", "home", user, "webapps", application) }

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

## Local Shared Area
# These are the list of files and directories that you want
# to share between the releases of your application on a particular
# server. It uses the same shared area as the log files.
#
# NOTE: local areas trump global areas, allowing you to have some
# servers using local assets if required.
#
# So if you have an 'upload' directory in public, add 'public/upload'
# to the :local_shared_dirs array.
# If you want to share the database.yml add 'config/database.yml'
# to the :local_shared_files array.
#
# The shared area is prepared with 'deploy:setup' and all the shared
# items are symlinked in when the code is updated.
# set :local_shared_dirs, %w(public/upload)
set :local_shared_files, %w(config/database.yml)

## Global Shared Area
# These are the list of files and directories that you want
# to share between all releases of your application across all servers.
# For it to work you need a directory on a network file server shared
# between all your servers. Specify the path to the root of that area
# in :global_shared_path. Defaults to the same value as :shared_path.
# set :global_shared_path, "/srv/share/myapp"
#
# NOTE: local areas trump global areas, allowing you to have some
# servers using local assets if required.
#
# Beyond that it is the same as the local shared area.
# So if you have an 'upload' directory in public, add 'public/upload'
# to the :global_shared_dirs array.
# If you want to share the database.yml add 'config/database.yml'
# to the :global_shared_files array.
#
# The shared area is prepared with 'deploy:setup' and all the shared
# items are symlinked in when the code is updated.
# set :global_shared_dirs, %w(public/upload)
# set :global_shared_files, %w(config/database.yml)

# Forces a Pty so that svn+ssh repository access will work. You
# don't need this if you are using a different SCM system. Note that
# ptys stop shell startup scripts from running.
default_run_options[:pty] = true

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

task :setup_production_database_configuration do
  the_host = Capistrano::CLI.ui.ask("Database IP address: ")
  database_name = Capistrano::CLI.ui.ask("Database name: ")
  database_user = Capistrano::CLI.ui.ask("Database username: ")
  pg_password = Capistrano::CLI.password_prompt("Database user password: ")

  require 'yaml'

  spec = {
    "#{rails_env}" => {
      "adapter" => "postgresql",
      "database" => database_name,
      "username" => database_user,
      "host" => the_host,
      "password" => pg_password
    }
  }

  run "mkdir -p #{shared_path}/config"
  put(spec.to_yaml, "#{shared_path}/config/database.yml")
end
after "deploy:setup", :setup_production_database_configuration && "deploy:migrate"
