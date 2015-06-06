module Mv
  module Core
    module Validation
      module ActiveModelPresenter
        class Format < Base
          def option_names
            super + [:with]
          end

          def validation_name
            :format
          end
        end
      end
    end
  end
end
