require 'mv/core/db/migration_validator'

module Mv
  module Core
    module Db
      module Helpers
        module TableValidators
          attr_accessor :table_name
          
          def table_validators
            Mv::Core::Db::MigrationValidator.where(table_name: table_name)
          end
        end
      end
    end
  end
end