$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'rspec/its'
require 'pry-byebug'
require 'mv-test'
require 'mv-core'
require 'shoulda'
require 'factory_girl'
require 'capybara'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ActiveRecord::Migration.verbose = false

require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
end
