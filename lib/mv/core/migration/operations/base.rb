module Mv
  module Core
    module Migration
      module Operations
        class Base
          attr_reader :version, :table_name
          
          def initialize version, table_name
            @version = version
            @table_name = table_name
          end

          def execute validators
            raise NotImplementedError
          end
        end
      end
    end
  end
end