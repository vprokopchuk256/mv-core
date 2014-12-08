require 'mv/core/db/helpers/table_validators'

module Mv
  module Core
    module Migration
      module Operations
        class DropTable
          include Mv::Core::Db::Helpers::TableValidators

          def initialize(table_name)
            self.table_name = table_name
          end

          def execute
            delete_table_validators
          end
        end
      end
    end
  end
end