require 'mv/core/constraints/base'

module Mv
  module Core
    module Constraints
      class Index < Base
        def initialize(name, options)
          super name, options
        end
      end
    end
  end
end