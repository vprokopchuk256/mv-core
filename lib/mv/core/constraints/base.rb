module Mv
  module Core
    module Constraints
      class Base
        attr_reader :name, :options, :validators

        def initialize name, options
          @name = name
          @options = options
          @validators = []
        end
        
        def create
        end

        def delete
        end

        def register validator
          route = validator.containers.find do |container_name, container_options| 
            routed_by?(container_name, container_options) 
          end

          validators << validator if route

          return route
        end

        private 
        
        def routed_by? container_name, container_options
          container_name.to_s == name.to_s && 
          container_options.length == options.length &&
          container_options.all? do |key, value| 
            options.with_indifferent_access[key].to_s == container_options[key].to_s 
          end
        end
      end
    end
  end
end