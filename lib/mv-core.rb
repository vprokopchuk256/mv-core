require 'rails'
require 'active_record'

require 'mv/core/active_record/connection_adapters/abstract_adapter_decorator'
require 'mv/core/active_record/connection_adapters/table_definition_decorator'
require 'mv/core/active_record/schema_dumper_decorator'
require 'mv/core/active_record/migration_decorator'
require 'mv/core/railtie'

ActiveSupport.on_load(:active_record) do
  ::ActiveRecord::ConnectionAdapters::TableDefinition.send(:prepend, Mv::Core::ActiveRecord::ConnectionAdapters::TableDefinitionDecorator)
  ::ActiveRecord::SchemaDumper.send(:prepend, Mv::Core::ActiveRecord::SchemaDumperDecorator)
  ::ActiveRecord::Migration.send(:prepend, Mv::Core::ActiveRecord::MigrationDecorator)
  
  ActiveSupport.run_load_hooks(:mv_core)
end

