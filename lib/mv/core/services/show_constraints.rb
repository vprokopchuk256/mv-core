require 'mv/core/services/load_constraints'
require 'mv/core/presenter/constraint/description'
require 'mv/core/presenter/validation/base'

module Mv
  module Core
    module Services
      class ShowConstraints
        attr_reader :tables

        def initialize(tables)
          @tables = tables.present? ? tables : Mv::Core::Db::MigrationValidator.pluck(:table_name)
        end

        def execute
          existing_constraints.each do |constraint|
            say_with_time("#{Mv::Core::Presenter::Constraint::Description.new(constraint.description)}") do
              constraint.validations.each do |validation|
                say("#{Mv::Core::Presenter::Validation::Base.new(validation)}")
              end
            end
          end
        end

        private

        def say_with_time msg, &block
          ::ActiveRecord::Migration::say_with_time(msg, &block)
        end

        def say msg
          ::ActiveRecord::Migration::say(msg, true)
        end

        def existing_constraints
          Mv::Core::Services::LoadConstraints.new(tables).execute
        end
      end
    end
  end
end