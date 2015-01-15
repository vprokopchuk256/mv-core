require 'mv/core/services/create_migration_validators_table.rb'

module Mv
  module Core
    class Railtie < ::Rails::Railtie
      initializer 'mv-core.initilization.migration_validators_table', after: 'active_record.initialize_database' do
        # Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
      end
    end
  end
end
