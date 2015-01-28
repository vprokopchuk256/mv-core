require 'mv/core/validation/active_model_presenter/base'

module Mv
  module Core
    module Validation
      module ActiveModelPresenter
        class Exclusion < Base
          def option_names
            super + [:in]
          end

          def validation_name
            :exclusion
          end
        end
      end
    end
  end
end