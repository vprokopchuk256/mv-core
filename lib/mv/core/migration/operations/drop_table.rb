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
        end
      end
    end
  end
end