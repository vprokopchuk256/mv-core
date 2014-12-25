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
          deletions.each(&:delete) if deletions
          updates.each{|old_constraint, new_constraint| old_constraint.update(new_constraint)} if updates
          additions.each(&:create) if additions
        end
      end
    end
  end
end