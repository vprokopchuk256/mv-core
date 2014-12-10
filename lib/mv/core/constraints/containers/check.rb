require 'mv/core/constraints/containers/base'

module Mv
  module Core
    module Constraints
      module Containers
        class Check < Base
          def initialize(name, options)
            super name, options
          end
        end
      end
    end
  end
end