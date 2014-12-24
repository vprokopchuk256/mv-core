require 'mv/core/constraint/description'

module Mv
  module Core
    module Constraint
      class Base
        attr_reader :description, :validators

        delegate :name, :type, :options, to: :description

        def initialize description
          @description = description
          @validators = []
        end
        
        def create
        end

        def delete
        end
      end
    end
  end
end