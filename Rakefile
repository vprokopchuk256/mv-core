require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development, :test)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "mv-core"
  gem.homepage = "http://github.com/vprokopchuk256/mv-core"
  gem.license = "MIT"
  gem.summary = "Trigger & check constraints in migrations similiar to ActiveRecord validations. Core classes"
  gem.description = "Trigger & check constraints in migrations. Allows developer to define database constraints in a ActiveRecord validation like manner. Almost all known validation are supported."
  gem.email = "vprokopchuk@gmail.com"
  gem.authors = ["Valeriy Prokopchuk"]
  gem.files = Dir.glob('lib/**/*.rb')
end
Jeweler::RubygemsDotOrgTasks.new

require 'rspec/core'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = FileList['spec/**/*_spec.rb']
end

RSpec::Core::RakeTask.new(:rcov) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "mv-core #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
