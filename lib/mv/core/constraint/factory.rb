require 'mv/core/constraint/trigger'
require 'mv/core/constraint/check'
require 'mv/core/constraint/index'

module Mv
  module Core
    module Constraint
      class Factory
        def create_constraints routes
          routes.inject([]) do |res, pair|
            res << create_constraint(pair.first, pair.last)
            res
          end
        end

        def load_constraints validators
          return validators.inject([]) do |constraints, validator|
            constraints + create_constraints(distribute_valdator(constraints, validator))
          end
        end

        private

        def create_constraint name, options
          type = options.with_indifferent_access[:type]
          klass = "Mv::Core::Constraint::#{type.to_s.camelize}".constantize
          klass.new(name, options)
        end

        def distribute_valdator constraints, validator
          distributed_routes = visit_constraints(constraints, validator)

          non_distributed_routes = validator.constraints.clone

          distributed_routes.each do |name_route_pair|
            non_distributed_routes.delete(name_route_pair.first)
          end

          non_distributed_routes
        end

        def visit_constraints constraints, validator
          constraints.collect{ |constraint| constraint.register(validator) }.compact
        end
      end
    end
  end
end