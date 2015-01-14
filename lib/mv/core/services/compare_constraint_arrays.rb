module Mv
  module Core
    module Services
      class CompareConstraintArrays
        attr_reader :old_constraints, :new_constraints

        def initialize(old_constraints, new_constraints)
          @old_constraints = old_constraints
          @new_constraints = new_constraints
        end

        def execute
          {
            deleted: deleted_constraints, 
            updated: updated_constraints, 
            added: added_constraints
          }.delete_if{ |key, value| value.blank? }
        end

        private 

        def deleted_constraints
          old_constraints.select do |old_constraint| 
            new_constraints.none? do |new_constraint| 
              old_constraint.description == new_constraint.description
            end
          end
        end

        def updated_constraints
          old_constraints.inject([]) do |res, old_constraint| 
            new_constraints.select do |new_constraint| 
              old_constraint.description == new_constraint.description &&
              old_constraint.validations.sort != new_constraint.validations.sort
            end.each{|new_constraint| res << [old_constraint, new_constraint]}
            res
          end
        end

        def added_constraints
          new_constraints.select do |new_constraint| 
            old_constraints.none? do |old_constraint| 
              old_constraint.description == new_constraint.description
            end
          end
        end
      end
    end
  end
end