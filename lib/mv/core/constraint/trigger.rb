require_relative 'base'

module Mv
  module Core
    module Constraint
      class Trigger < Base
        attr_reader :event

        def initialize description
          super
          @event = @description.options[:event].try(:to_sym)
        end

        def update?
          event == :update
        end
      end
    end
  end
end
