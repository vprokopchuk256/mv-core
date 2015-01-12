require 'mv/core/migration/base'

module Mv
  module Core
    module ActiveRecord
      module ConnectionAdapters
        module TableDefinitionDecorator
          def column column_name, type, opts = {}
            Mv::Core::Migration::Base.add_column(name, column_name, opts.delete(:validates))  

            super
          end

          def validates column_name, opts
            Mv::Core::Migration::Base.change_column(name, column_name, opts)  
          end
        end
      end
    end
  end
end