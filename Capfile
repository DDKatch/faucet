require 'capistrano/setup'
require 'capistrano/rvm'
require "capistrano/scm/git"
require 'capistrano/deploy'
require 'capistrano/rails'
require 'capistrano/bundler'
require 'capistrano/puma'
install_plugin Capistrano::Puma, load_hooks: false  # Default puma tasks without hooks

install_plugin Capistrano::SCM::Git

Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r  }
