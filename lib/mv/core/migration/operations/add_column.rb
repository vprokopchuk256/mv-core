require 'mv/core/migration/operations/base'

module Mv
  module Core
    module Migration
      module Operations
        class AddColumn < Base
          attr_reader :column_name, :opts

          def initialize(version, table_name, column_name, opts)
            super version, table_name
            @column_name = column_name
            @opts = opts
          end
        end
      end
    end
  end
end