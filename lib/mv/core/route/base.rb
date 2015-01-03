require 'mv/core/constraint/description'

module Mv
  module Core
    module Route
      class Base
        attr_reader :validation

        def initialize(validation)
          @validation = validation
        end

        def route
          [Mv::Core::Constraint::Description.new(validation.index_name, :index)]
        end

        protected

        def description(name, type, opts = {})
          Mv::Core::Constraint::Description.new(name, type, opts)
        end
      end
    end
  end
end