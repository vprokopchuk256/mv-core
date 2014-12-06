require 'mv/core/db/helpers/table_validators'

module Mv
  module Core
    module Migration
      module Operations
        class RenameTable
          include Mv::Core::Db::Helpers::TableValidators

          attr_reader :new_table_name

          def initialize(table_name, new_table_name)
            self.table_name = table_name

            @new_table_name = new_table_name
          end
        end
      end
    end
  end
end