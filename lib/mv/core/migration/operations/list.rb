module Mv
  module Core
    module Migration
      module Operations
        class List
          attr_reader :operations

          def initialize()
            @operations = []  
          end

          def add_operation(operation)
            operations << operation
          end

          def execute
            operations.each(&:execute)
            operations.clear
          end

          def tables
            operations.collect(&:table_name)
          end
        end
      end
    end
  end
end