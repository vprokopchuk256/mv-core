require 'mv/core/constraint/description'

module Mv
  module Core
    module Router
      class Check
        def route validation
          [Mv::Core::Constraint::Description.new(validation.check_name, :check)]
        end
      end
    end
  end
end