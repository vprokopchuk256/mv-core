require 'mv/core/constraints/containers/base'

module Mv
  module Core
    module Constraints
      module Containers
        class Index < Base
          def initialize(name, options)
            super name, options
          end
        end
      end
    end
  end
end