require 'mv-core'
require 'rspec'
require 'rspec/its'
require 'shoulda'
require 'factory_girl'

::ActiveRecord::Migration.verbose = false

require 'coveralls'
Coveralls.wear!

FactoryGirl.find_definitions

Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'shared/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

	config.before :each do
    ::ActiveRecord::Base.remove_connection if ::ActiveRecord::Base.connected?
    ::ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")
  end
end
