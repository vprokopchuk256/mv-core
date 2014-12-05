require 'mv/core/migration/operations/base'

module Mv
  module Core
    module Migration
      module Operations
        class RenameTable < Base
          attr_reader :new_table_name

          def initialize(table_name, new_table_name)
            super table_name
            @new_table_name = new_table_name
          end
        end
      end
    end
  end
end