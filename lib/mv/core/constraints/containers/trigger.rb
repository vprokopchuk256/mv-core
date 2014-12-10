require 'mv/core/constraints/containers/base'

module Mv
  module Core
    module Constraints
      module Containers
        class Trigger < Base
          attr_reader :event
          
          def initialize(name, options)
            super name, options
            @event = @options.with_indifferent_access[:event]
          end
        end
      end
    end
  end
end