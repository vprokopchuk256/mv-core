require_relative 'base'

module Mv
  module Core
    module Validation
      module ActiveModelPresenter
        class Uniqueness < Base
          def validation_name
            :uniqueness
          end
        end
      end
    end
  end
end
