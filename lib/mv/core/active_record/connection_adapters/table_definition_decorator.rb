require 'mv/core/migration/base'
require 'mv/core/services/parse_validation_options'

module Mv
  module Core
    module ActiveRecord
      module ConnectionAdapters
        module TableDefinitionDecorator
          def column column_name, type, opts = {}
            Mv::Core::Migration::Base.add_column(name, column_name, params(opts))  

            super
          end

          def validates column_name, opts
            Mv::Core::Migration::Base.change_column(name, column_name, opts)  
          end

          private

          def params opts
            Mv::Core::Services::ParseValidationOptions.new(opts).execute
          end
        end
      end
    end
  end
end