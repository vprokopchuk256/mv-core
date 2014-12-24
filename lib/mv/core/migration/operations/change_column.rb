require 'mv/core/db/helpers/column_validators'

module Mv
  module Core
    module Migration
      module Operations
        class ChangeColumn
          include Mv::Core::Db::Helpers::ColumnValidators

          attr_reader :opts

          def initialize(table_name, column_name, opts = nil)
            self.table_name = table_name
            self.column_name = column_name
            @opts = opts || {}
          end

          def execute
            opts.each do |validation_type, validator_opts|
              update_column_validator(validation_type, validator_opts)
            end
          end
        end
      end
    end
  end
end