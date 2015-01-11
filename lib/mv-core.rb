require 'rails'
require 'active_record'

require 'mv/core/railtie'

ActiveSupport.on_load(:active_record) do
  ::ActiveRecord::ConnectionAdapters::TableDefinition.send(:prepend, Mv::Core::ActiveRecord::ConnectionAdapters::TableDefinitionDecorator)
  ::ActiveRecord::Migration.send(:prepend, Mv::Core::ActiveRecord::MigrationDecorator)
  
  ActiveSupport.run_load_hooks(:mv_core)
end

