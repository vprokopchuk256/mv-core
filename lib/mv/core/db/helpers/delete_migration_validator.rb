require 'mv/core/db/migration_validator'

module Mv
  module Core
    module Db
      module Helpers
        module DeleteMigrationValidator
          def delete_migration_validator table_name, column_name, validator_name
            Mv::Core::Db::MigrationValidator.where(table_name: table_name, 
                                                   column_name: column_name, 
                                                   validator_name: validator_name)
                                            .delete_all > 0
          end
        end
      end
    end
  end
end