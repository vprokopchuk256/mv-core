require 'mv/core/constraint/trigger'
require 'mv/core/constraint/check'
require 'mv/core/constraint/index'

module Mv
  module Core
    module Constraint
      class Factory
        def create_constraints descriptions
          descriptions.inject([]) do |res, description|
            res << create_constraint(description)
            res
          end
        end

        def create_constraint description
          klass = "Mv::Core::Constraint::#{description.type.to_s.camelize}".constantize
          klass.new(description)
        end
      end
    end
  end
end