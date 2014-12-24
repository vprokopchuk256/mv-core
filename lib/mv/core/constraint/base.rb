require 'mv/core/constraint/description'

module Mv
  module Core
    module Constraint
      class Base
        attr_reader :description, :validations

        delegate :name, :type, :options, to: :description

        def initialize description
          @description = description
          @validations = []
        end
        
        def create
        end

        def delete
        end
      end
    end
  end
end