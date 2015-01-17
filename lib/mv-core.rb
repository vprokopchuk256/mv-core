require 'rails'
require 'active_record'

require 'mv/core/active_record/connection_adapters/abstract_adapter_decorator'
require 'mv/core/active_record/connection_adapters/table_definition_decorator'
require 'mv/core/active_record/connection_adapters/table_decorator'
require 'mv/core/active_record/schema_dumper_decorator'
require 'mv/core/active_record/schema_decorator'
require 'mv/core/active_record/migration_decorator'
require 'mv/core/active_record/migration/command_recorder_decorator'
require 'mv/core/railtie'

ActiveSupport.on_load(:active_record) do
  ::ActiveRecord::ConnectionAdapters::TableDefinition.send(:prepend, Mv::Core::ActiveRecord::ConnectionAdapters::TableDefinitionDecorator)
  ::ActiveRecord::ConnectionAdapters::Table.send(:prepend, Mv::Core::ActiveRecord::ConnectionAdapters::TableDecorator)
  ::ActiveRecord::SchemaDumper.send(:prepend, Mv::Core::ActiveRecord::SchemaDumperDecorator)
  ::ActiveRecord::Schema.send(:prepend, Mv::Core::ActiveRecord::SchemaDecorator)
  ::ActiveRecord::Migration.send(:prepend, Mv::Core::ActiveRecord::MigrationDecorator)
  ::ActiveRecord::Migration::CommandRecorder.send(:prepend, Mv::Core::ActiveRecord::Migration::CommandRecorderDecorator)
  
  ActiveSupport.run_load_hooks(:mv_core)
end

