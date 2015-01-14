module Mv
  module Core
    module Services
      class CompareConstraints
        attr_reader :old_constraint, :new_constraint

        def initialize(old_constraint, new_constraint)
          @old_constraint = old_constraint
          @new_constraint = new_constraint
        end

        def execute
          {
            deleted: old_validations - new_validations, 
            added: new_validations - old_validations
          }.delete_if{ |key, value| value.blank? }
        end

        private 

        def old_validations
          @old_validations ||= old_constraint.try(:validations) || []
        end

        def new_validations
          @new_validations ||= new_constraint.try(:validations) || []
        end
      end
    end
  end
end