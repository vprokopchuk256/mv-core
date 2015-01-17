module Mv
  module Core
    module ActiveRecord
      module ConnectionAdapters
        module TableDecorator
          def validates column_name, opts
            @base.validates(name, column_name, opts)
          end
        end
      end
    end
  end
end