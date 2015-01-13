require 'mv/core/services/create_migration_validators_table'

module Mv
  module Core
    module ActiveRecord
      module SchemaDecorator
        
        def define *args
          Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
          super
          Mv::Core::Migration::Base.execute()
        end
      end
    end
  end
end