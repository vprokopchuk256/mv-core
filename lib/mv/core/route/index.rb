module Mv
  module Core
    module Route
      class Index
        attr_reader :validation

        def initialize(validation)
          @validation = validation
        end

        def route
          [Mv::Core::Constraint::Description.new(validation.index_name, :index)]
        end
      end
    end
  end
end