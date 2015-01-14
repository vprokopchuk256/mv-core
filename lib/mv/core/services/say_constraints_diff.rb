require 'mv/core/services/compare_constraints'
require 'mv/core/presenter/validation/base'
require 'mv/core/presenter/constraint/description'

module Mv
  module Core
    module Services
      class SayConstraintsDiff
        attr_reader :old_constraint, :new_constraint

        def initialize(old_constraint, new_constraint)
          @old_constraint = old_constraint   
          @new_constraint = new_constraint
        end

        def execute
          ::ActiveRecord::Migration.say_with_time("#{constraint_operation} #{constraint_presenter}") do
            comparison[:deleted].each do |validation|
              say("delete #{validation_presenter(validation)}")
            end if comparison[:deleted]

            comparison[:added].each do |validation|
              say("create #{validation_presenter(validation)}")
            end if comparison[:added]

            yield
          end unless comparison.blank?
        end

        private

        def constraint_operation
          return 'create' unless old_constraint
          return 'delete' unless new_constraint
          'update'
        end

        def constraint_presenter
          Mv::Core::Presenter::Constraint::Description.new((old_constraint || new_constraint).description)
        end

        def validation_presenter validation
          Mv::Core::Presenter::Validation::Base.new(validation)
        end

        def comparison
          @comparison ||= Mv::Core::Services::CompareConstraints.new(old_constraint, new_constraint)
                                                                .execute
        end

        def say_with_time msg, &block
          ::ActiveRecord::Migration.say_with_time(msg, &block)
        end
          
        def say msg
          ::ActiveRecord::Migration.say(msg, true)
        end
      end
    end
  end
end