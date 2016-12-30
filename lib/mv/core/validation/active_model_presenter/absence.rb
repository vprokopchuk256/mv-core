require_relative 'base'

module Mv
  module Core
    module Validation
      module ActiveModelPresenter
        class Absence < Base
          def validation_name
            :absence
          end
        end
      end
    end
  end
end
