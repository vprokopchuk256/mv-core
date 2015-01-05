require 'mv/core/constraint/builder/factory'

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
            builder(constraint_to_delete).delete
          end if deletions
        end

        def update
          updates.each do |old_constraint, new_constraint| 
            builder(old_constraint).update(builder(new_constraint))
          end if updates
        end

        def create
          additions.each do |constraint_to_be_added|
            builder(constraint_to_be_added).create
          end if additions
        end
      end
    end
  end
end