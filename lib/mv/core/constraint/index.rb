require 'mv/core/constraint/base'

module Mv
  module Core
    module Constraint
      class Index < Base
        def initialize(name, options)
          super name, :index, options
        end
      end
    end
  end
end