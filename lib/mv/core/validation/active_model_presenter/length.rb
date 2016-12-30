require_relative 'base'

module Mv
  module Core
    module Validation
      module ActiveModelPresenter
        class Length < Base
          def option_names
            super + [:is, :in, :within, :maximum, :minimum, :too_short, :too_long]
          end

          def validation_name
            :length
          end
        end
      end
    end
  end
end
