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

          def routed_by? container_name, container_options
            container_name.to_s == name.to_s && 
            container_options.length == options.length &&
            container_options.all?{
              |key, value| options.with_indifferent_access[key].to_s == container_options[key].to_s
            }
          end
        end
      end
    end
  end
end