## Generated with 'brightbox' on 2011-08-24 13:56:07 +0100
gem 'brightbox', '>=2.3.9'
require 'brightbox/recipes'
require 'brightbox/passenger'

# Primary domain name of your application. Used in the Apache configs
set :domain, "unepwcmc-001.vm.brightbox.net"

## List of servers
server "unepwcmc-001.vm.brightbox.net", :app, :web, :db, :primary => true

set :branch, "master"
