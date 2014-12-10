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

          private

          def create_container name, options
            type = options.with_indifferent_access[:type]
            klass = "Mv::Core::Constraints::Containers::#{type.to_s.camelize}".constantize
            klass.new(name, options)
          end
          
        end
      end
    end
  end
end