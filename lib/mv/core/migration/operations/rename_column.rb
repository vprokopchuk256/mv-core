require 'mv/core/db/helpers/column_validators'

module Mv
  module Core
    module Migration
      module Operations
        class RenameColumn
          include Mv::Core::Db::Helpers::ColumnValidators

          attr_reader :new_column_name
          
          def initialize(table_name, column_name, new_column_name)
            self.table_name = table_name
            self.column_name = column_name
            
            @new_column_name = new_column_name
          end
        end
      end
    end
  end
end