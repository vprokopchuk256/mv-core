require 'mv/core/db/helpers/column_validators'
require 'mv/core/error'

module Mv
  module Core
    module Migration
      module Operations
        class AddColumn
          include Mv::Core::Db::Helpers::ColumnValidators

          attr_reader :opts

          def initialize(table_name, column_name, opts)
            self.table_name = table_name
            self.column_name = column_name
            @opts = opts
          end

          def execute
            opts.each do |validator_name, validator_opts|
              create_column_validator(validator_name, validator_opts)
            end
          end
        end
      end
    end
  end
end