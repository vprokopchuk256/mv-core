require 'mv/core/constraint/base'

module Mv
  module Core
    module Constraint
      class Check < Base
        def initialize(name, options)
          super name, :check, options
        end
      end
    end
  end
end