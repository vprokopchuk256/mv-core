require 'mv/core/constraint/base'

module Mv
  module Core
    module Constraint
      class Trigger < Base
        attr_reader :event
        
        def initialize description
          super 
          @event = @description.options[:event]
        end
      end
    end
  end
end