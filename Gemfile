if RUBY_VERSION =~ /2.2.3/
Encoding.default_external = Encoding::UTF_8
Encoding.default_internal = Encoding::UTF_8
end


source 'https://rubygems.org'
gem 'rails', '3.2.17'
gem 'pg'
gem 'googlecharts', :require => 'gchart'
gem 'iconv'

group :development do
  gem 'capistrano', '~> 3.4.0', require: false, group: :development
  gem 'capistrano-rails', '~> 1.1', require: false
  gem 'capistrano-bundler', '~> 1.1', require: false
  gem 'capistrano-rvm', '~> 0.1', require: false
  gem 'capistrano-passenger', '~> 0.1.1', require: false
end
