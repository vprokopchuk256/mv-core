require 'mv/core/constraint/description'

module Mv
  module Core
    module Constraint
      class Base
        attr_reader :description, :validators

        delegate :name, :type, :options, to: :description

        def initialize description
          @description = description
          @validators = []
        end
        
        def create
        end

        def delete
        end

        def register validator
          route = validator.constraints.find do |constraint_name, constraint_type, constraint_options| 
            routed_by?(constraint_name, constraint_type, constraint_options) 
          end

          validators << validator if route

          return route
        end

        private 
        
        def routed_by? constraint_name, constraint_type, constraint_options
          constraint_name.to_s == name.to_s && 
          constraint_type.to_s == type.to_s && 
          constraint_options.length == options.length &&
          constraint_options.all? do |key, value| 
            options.with_indifferent_access[key].to_s == constraint_options[key].to_s 
          end
        end
      end
    end
  end
end