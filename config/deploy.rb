require 'pry'
require 'mina/git'
require 'mina/bundler'
require 'mina/rails'
require 'mina/rvm'
require 'mina/rsync'
require 'yaml'

DEPLOY_CONF = YAML.load(File.read('config/deploy.yml'))

set :term_mode, nil
set :domain, DEPLOY_CONF['host']
set :user, DEPLOY_CONF['user']
set :deploy_to, '/var/faucet'
set :repository, DEPLOY_CONF['repository']
set :branch, DEPLOY_CONF['branch']
set :shared_paths, ['log', 'config/faucet.yml', 'config/secrets.yml', 'config/database.yml' ,'public/wallet', 'db/bitshares_faucet.sqlite3']
set :rsync_options, %w[-az --force --recursive --delete --delete-excluded --progress --exclude-from=.gitignore --exclude 'public/*']
set :wallet_params, DEPLOY_CONF['wallet_params']
set :wallet_import, DEPLOY_CONF['wallet_import']

task :environment do
  set :rvm_ruby_version, '2.2.3'
end

task :run_cli_wallet => :environment do
  queue! %[echo "#{wallet_import}" | /usr/local/bin/cli_wallet #{wallet_params}]
end

task :setup => :environment do
    queue! %[mkdir -p "#{deploy_to}/#{shared_path}/log"]
    queue! %[mkdir -p "#{deploy_to}/#{shared_path}/config"]
    queue! %[mkdir -p "#{deploy_to}/#{shared_path}/public/wallet"]
    queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/log"]
    queue! %[chmod g+rx,u+rwx "#{deploy_to}/#{shared_path}/config"]
end

task :deploy => :environment do
    deploy do
        invoke :'rsync:deploy'
        invoke :'deploy:link_shared_paths'
        invoke :'bundle:install'
        invole :'mina run_cli_wallet -d'
        invoke :'rails:db_migrate'
        invoke :'rails:assets_precompile'
        to :launch do
            queue "touch #{deploy_to}/tmp/restart.txt"
        end
    end
end

task :restart do
    queue 'sudo service nginx restart'
end

task :wallet do
    $script =
<<SCRIPT
      echo 'deploying wallet';
      rsync -az --force --delete --progress public/wallet/ #{domain}:#{deploy_to}/#{shared_path}/public/wallet;
SCRIPT
    exec $script
    to :launch do
        queue "touch #{deploy_to}/tmp/restart.txt"
    end
end
