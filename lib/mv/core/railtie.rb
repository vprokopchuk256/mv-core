require 'mv/core/services/uninstall'
require 'mv/core/services/delete_constraints'
require 'mv/core/services/create_constraints'

module Mv
  module Core
    class Railtie < ::Rails::Railtie
      rake_tasks do
        namespace :mv do
          task :uninstall => :environment  do
            Mv::Core::Services::Uninstall.new.execute
          end

          task :delete_constraints, [:tables] => :environment do |task, args|
            Mv::Core::Services::DeleteConstraints.new((args[:tables] || '').split(/\s+/)).execute
          end

          task :create_constraints, [:tables] => :environment do |task, args|
            Mv::Core::Services::CreateConstraints.new((args[:tables] || '').split(/\s+/)).execute
          end
        end
      end 
    end
  end
end
