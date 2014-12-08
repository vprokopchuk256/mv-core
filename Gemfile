source "http://rubygems.org"

gem 'railties', '~> 4.1'
gem 'activerecord', '~> 4.1'
gem 'i18n', github: 'svenfuchs/i18n'

group :development do
  gem 'jeweler', '~> 2.0'
  gem 'sqlite3', '~> 1.3'
  gem 'guard-rspec', require: false
end

group :test, :development do
  gem 'rspec', '~> 3.1'
  gem 'rspec-its'
  gem 'shoulda'
  gem 'pry-debugger'
  gem 'mv-test', '~> 1.0'
  gem 'factory_girl'
  gem 'coveralls', require: false
  if `uname` =~ /Darwin/
    gem 'rb-fsevent'
    gem 'terminal-notifier-guard'
  end
end

