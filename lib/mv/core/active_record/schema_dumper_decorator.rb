require 'mv/core/db/migration_validator'
require 'mv/core/services/create_migration_validators_table'
require 'mv/core/presenter/migration_validator'

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
            stream.puts("
              validates :#{migration_validator.table_name.to_sym}, 
                        :#{migration_validator.column_name.to_sym}, 
                        #{Mv::Core::Presenter::MigrationValidator.new(migration_validator)}
            ".squish.prepend('  ')) 
          end

          stream.puts('')
          super
        end
      end
    end
  end
end