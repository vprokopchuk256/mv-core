require_relative 'base'

module Mv
  module Core
    module Constraint
      module Builder
        class Trigger < Base
          delegate :event, :update?, to: :constraint
        end
      end
    end
  end
end
