require 'mv/core/db/migration_validator'
require 'mv/core/services/create_migration_validators_table'
require 'mv/core/presenter/validation/base' 

module Mv
  module Core
    module ActiveRecord
      module SchemaDumperDecorator
        def self.prepended(mod)
          mod.ignore_tables << 'migration_validators'
        end

        def dump(stream)
          Mv::Core::Services::CreateMigrationValidatorsTable.new(@connection).execute
          super
        end

        def trailer(stream)
          Mv::Core::Db::MigrationValidator.all.each do |migration_validator|
            stream.puts("#{Mv::Core::Presenter::Validation::Base.new(migration_validator.validation)}".prepend('  ')) 
          end

          stream.puts('')
          super
        end
      end
    end
  end
end