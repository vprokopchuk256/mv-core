module Mv
  module Core
    module Constraint
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
          route = validator.constraints.find do |constraint_name, constraint_options| 
            routed_by?(constraint_name, constraint_options) 
          end

          validators << validator if route

          return route
        end

        private 
        
        def routed_by? constraint_name, constraint_options
          constraint_name.to_s == name.to_s && 
          constraint_options.length == options.length &&
          constraint_options.all? do |key, value| 
            options.with_indifferent_access[key].to_s == constraint_options[key].to_s 
          end
        end
      end
    end
  end
end