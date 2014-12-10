module Mv
  module Core
    module Constraints
      module Containers
        class Base
          attr_reader :name, :options

          def initialize name, options
            @name = name
            @options = options
          end
          
          def create
          end

          def delete
          end
        end
      end
    end
  end
end