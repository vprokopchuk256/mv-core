require 'mv/core/constraint/description'

module Mv
  module Core
    module Constraint
      class Base
        include Comparable

        attr_reader :description, :validations

        delegate :name, :type, :options, to: :description

        def initialize description
          @description = description
          @validations = []
        end

        def <=> other_constraint
          [self.class.name, description, validations.sort] <=> [other_constraint.class.name, other_constraint.description, other_constraint.validations.sort]
        end
        
        def create
        end

        def delete
        end
      end
    end
  end
end