DEPLOY_CONF = YAML.load(File.read('config/deploy.yml'))

lock "3.8.0"

set :rvm_ruby_version, DEPLOY_CONF['ruby_version']

server DEPLOY_CONF['host'], roles: [:web, :db, :app], primary: true

set :repo_url,        DEPLOY_CONF['repository']
set :application,     DEPLOY_CONF['application']	
set :user,            DEPLOY_CONF['user']
set :puma_threads,    DEPLOY_CONF['threads']
set :puma_workers,    DEPLOY_CONF['workers']

# Don't change these unless you know what you're doing
set :pty, true
set :deploy_to,       "/var/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/puma.sock"
# set :puma_bind,       "tcp://78.155.207.109:4000"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{shared_path}/log/puma/puma.access.log"
set :puma_error_log,  "#{shared_path}/log/puma/puma.error.log"
set :ssh_options,     { forward_agent: true, user: fetch(:user), keys: %w(~/.ssh/id_rsa.pub) }

## Defaults:
# set :scm,           :git
set :branch,          DEPLOY_CONF['branch']
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
set :linked_files, %w{config/database.yml config/secrets.yml config/faucet.yml db/bitshares_faucet.sqlite3}
set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets}

# ps aux | grep puma    # Get puma pid
# kill -s SIGUSR2 pid   # Restart puma
# kill -s SIGTERM pid   # Stop puma
