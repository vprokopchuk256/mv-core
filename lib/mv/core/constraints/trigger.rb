require 'mv/core/constraints/base'

module Mv
  module Core
    module Constraints
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