require 'mv/core/migration/operations/base'

module Mv
  module Core
    module Migration
      module Operations
        class RenameTable < Base
          attr_reader :new_table_name

          def initialize(version, table_name, new_table_name)
            super version, table_name
            @new_table_name = new_table_name
          end
        end
      end
    end
  end
end