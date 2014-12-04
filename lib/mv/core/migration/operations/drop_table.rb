require 'mv/core/migration/operations/base'

module Mv
  module Core
    module Migration
      module Operations
        class DropTable < Base
          def initialize(version, table_name)
            super version, table_name
          end
        end
      end
    end
  end
end