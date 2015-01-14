require 'mv/core/constraint/builder/factory'
require 'mv/core/services/say_constraints_diff'

module Mv
  module Core
    module Services
      class SynchronizeConstraints
        attr_reader :additions, :updates, :deletions

        def initialize(additions, updates, deletions)
          @additions = additions
          @updates = updates
          @deletions = deletions
        end

        def execute
          delete
          update
          create
        end

        private 

        def builder(constraint)
          Mv::Core::Constraint::Builder::Factory.create_builder(constraint)
        end

        def delete
          deletions.each do |constraint_to_delete|
            Mv::Core::Services::SayConstraintsDiff.new(constraint_to_delete, nil).execute do
              builder(constraint_to_delete).delete
            end
          end if deletions
        end

        def update
          updates.each do |old_constraint, new_constraint| 
            Mv::Core::Services::SayConstraintsDiff.new(old_constraint, new_constraint).execute do
              builder(old_constraint).update(builder(new_constraint))
            end
          end if updates
        end

        def create
          additions.each do |constraint_to_be_added|
            Mv::Core::Services::SayConstraintsDiff.new(nil, constraint_to_be_added).execute do
              builder(constraint_to_be_added).create
            end
          end if additions
        end
      end
    end
  end
end