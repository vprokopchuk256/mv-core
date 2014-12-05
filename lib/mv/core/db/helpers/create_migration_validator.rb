require 'mv/core/db/migration_validator'

module Mv
  module Core
    module Db
      module Helpers
        module CreateMigrationValidator
          def create_migration_validator table_name, column_name, validator_name, opts
            if opts
              Mv::Core::Db::MigrationValidator.create!(
                table_name: table_name, 
                column_name: column_name, 
                validator_name: validator_name, 
                options: opts == true ? {} : opts
              )
            end
          end
        end
      end
    end
  end
end