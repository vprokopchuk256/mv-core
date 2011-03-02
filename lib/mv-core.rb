require 'active_support'
require 'active_record'

require File.expand_path(File.dirname(__FILE__)) + '/options'

require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/active_record/connection_adapters/table'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/active_record/connection_adapters/abstract_adapter'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/active_record/connection_adapters/native_adapter'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/active_record/connection_adapters/table_definition'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/active_record/base'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/active_record/migration'

require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/core/db_validator'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/core/adapter_wrapper'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/core/statement_builder'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/core/validator_definition'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/core/validator_container'
require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/core/validator_router'

require File.expand_path(File.dirname(__FILE__)) + '/migration_validators/adapters/base'

module MigrationValidators
  class MigrationValidatorsException < Exception; end
  class << self
    def validators
      @validators ||= {}
    end

    def dumpers
      @dumpers ||= {}
    end

    def register_adapter! name, klass
      validators[name] = klass
      reload_validator
    end

    def register_dumper! name, klass
      dumpers[name] = klass
    end

    def current_connection_adapter
      ::ActiveRecord::Base.connection_pool.spec.config[:adapter]
    end
  
    def dumper 
      @dumper || dumpers[current_adapter].new
    end

    def adapter= adapter
      @adapter = adapter
      @validator = nil
    end

    def adapter
      @adapter
    end

    def validator 
      @validator ||= MigrationValidators::Core::AdapterWrapper.new(@adapter || validators[current_connection_adapter].new)
    end

    def reload_validator
      @adapter = nil
      @validator = nil
    end

    def load!
      ::ActiveRecord::ConnectionAdapters::TableDefinition.class_eval { include MigrationValidators::ActiveRecord::ConnectionAdapters::TableDefinition }
      ::ActiveRecord::ConnectionAdapters::Table.class_eval { include MigrationValidators::ActiveRecord::ConnectionAdapters::Table }
      ::ActiveRecord::ConnectionAdapters::AbstractAdapter.class_eval { include MigrationValidators::ActiveRecord::ConnectionAdapters::AbstractAdapter }
      ::ActiveRecord::Base.instance_eval { include MigrationValidators::ActiveRecord::Base }
      ::ActiveRecord::Migration.instance_eval { include MigrationValidators::ActiveRecord::Migration }
      #ActiveRecord::SchemaDumper.class_eval { include MigrationValidators::SchemaDumper }

      ::ActiveRecord::SchemaDumper.ignore_tables << MigrationValidators.migration_validators_table_name.to_s
    end
  end
end

Dir.glob('adapters/**/*.rb').each {|file_name| require file_name}

if defined?(Rails::Railtie)
  module Foreigner
    class Railtie < Rails::Railtie
      initializer 'migration-validators.load' do
        ActiveSupport.on_load :active_record do
          MigrationValidators.load!
        end
      end
    end
  end
else
  MigrationValidators.load!
end
