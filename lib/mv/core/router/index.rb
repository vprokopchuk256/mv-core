require 'mv/core/constraint/description'

module Mv
  module Core
    module Router
      class Index
        def route validation
          [Mv::Core::Constraint::Description.new(validation.index_name, :index)]
        end
      end
    end
  end
end