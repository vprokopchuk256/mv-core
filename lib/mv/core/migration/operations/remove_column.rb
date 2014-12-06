require 'mv/core/db/helpers/column_validators'

module Mv
  module Core
    module Migration
      module Operations
        class RemoveColumn
          include Mv::Core::Db::Helpers::ColumnValidators
          
          def initialize(table_name, column_name)
            self.table_name = table_name
            self.column_name = column_name
          end
        end
      end
    end
  end
end