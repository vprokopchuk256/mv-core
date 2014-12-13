require 'mv/core/constraints/containers/trigger'
require 'mv/core/constraints/containers/check'
require 'mv/core/constraints/containers/index'

module Mv
  module Core
    module Constraints
      module Containers
        class Factory
          def create_containers routes
            routes.inject([]) do |res, pair|
              res << create_container(pair.first, pair.last)
              res
            end
          end

          def load_containers validators
            return validators.inject([]) do |containers, validator|
              containers + create_containers(distribute_valdator(containers, validator))
            end
          end

          private

          def create_container name, options
            type = options.with_indifferent_access[:type]
            klass = "Mv::Core::Constraints::Containers::#{type.to_s.camelize}".constantize
            klass.new(name, options)
          end

          def distribute_valdator containers, validator
            distributed_routes = visit_containers(containers, validator)

            non_distributed_routes = validator.containers.clone

            distributed_routes.each do |name_route_pair|
              non_distributed_routes.delete(name_route_pair.first)
            end

            non_distributed_routes
          end

          def visit_containers containers, validator
            containers.collect{ |container| container.visit(validator) }.compact
          end
        end
      end
    end
  end
end