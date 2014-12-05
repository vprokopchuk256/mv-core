require 'mv/core/migration/operations/base'

module Mv
  module Core
    module Migration
      module Operations
        class DropTable < Base
          def initialize(table_name)
            super table_name
          end
        end
      end
    end
  end
end