module Mv
  module Core
    module Migration
      module Operations
        class Base
          attr_reader :table_name
          
          def initialize table_name
            @table_name = table_name
          end

          def execute
            raise NotImplementedError
          end
        end
      end
    end
  end
end