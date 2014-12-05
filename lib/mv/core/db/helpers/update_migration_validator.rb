require 'mv/core/db/migration_validator'

module Mv
  module Core
    module Db
      module Helpers
        module UpdateMigrationValidator
          def update_migration_validator table_name, column_name, validator_name, opts
            return false unless opts.present? 

            Mv::Core::Db::MigrationValidator.where(table_name: table_name, 
                                                   column_name: column_name, 
                                                   validator_name: validator_name)
                                            .update_all(options: opts == true ? {} : opts) > 0
          end
        end
      end
    end
  end
end