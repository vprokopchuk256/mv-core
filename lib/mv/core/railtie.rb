require 'mv/core/services/create_migration_validators_table.rb'
require 'mv/core/active_record/connection_adapters/abstract_adapter_decorator'
require 'mv/core/active_record/connection_adapters/table_definition_decorator'

module Mv
	module Core
		class Railtie < ::Rails::Railtie
			initializer 'mv-core.initilization.migration_validators_table', after: 'active_record.initialize_database' do
				Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
			end

			initializer 'mv-core.initialization.active_record', after: 'mv-core.initilization.migration_validators_table' do
				::ActiveRecord::Base.connection.class.send(:prepend, Mv::Core::ActiveRecord::ConnectionAdapters::AbstractAdapterDecorator)
				::ActiveRecord::ConnectionAdapters::TableDefinition.send(:prepend, Mv::Core::ActiveRecord::ConnectionAdapters::TableDefinitionDecorator)
			end
		end
	end
end