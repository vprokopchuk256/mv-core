require_relative 'base'

module Mv
  module Core
    module Validation
      module ActiveModelPresenter
        class Presence < Base
          def validation_name
            :presence
          end
        end
      end
    end
  end
end
