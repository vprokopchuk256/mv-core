require 'mv/core/db/migration_validator'
require 'mv/core/migration/operations/list'
require 'mv/core/migration/operations/factory'
require 'mv/core/services/load_constraints'
require 'mv/core/services/compare_constraint_arrays'
require 'mv/core/services/synchronize_constraints'

module Mv
  module Core
    module Migration
      class Base
        include Singleton

        SUPPORTED_METHODS = %i{ add_column remove_column rename_column 
                                change_column rename_table drop_table}

        attr_reader :operations_list, :operations_factory
        
        def initialize()
          @operations_list = Mv::Core::Migration::Operations::List.new
          @operations_factory = Mv::Core::Migration::Operations::Factory.new()
        end

        SUPPORTED_METHODS.each do |operation_name|
          define_method operation_name do |*args|

            unless disabled_validations?
              operation = operations_factory.create_operation(operation_name, *args)
              operations_list.add_operation(operation)
            end
          end
        end

        def execute
          constraints_loader = Mv::Core::Services::LoadConstraints.new(operations_list.tables)

          old_constraints = constraints_loader.execute

          operations_list.execute()

          new_constraints = constraints_loader.execute

          constraints_comparizon = Mv::Core::Services::CompareConstraintArrays.new(old_constraints, new_constraints)
                                                                                   .execute

          Mv::Core::Services::SynchronizeConstraints.new(constraints_comparizon[:added], 
                                                         constraints_comparizon[:updated], 
                                                         constraints_comparizon[:deleted])
                                                    .execute
        end

        def add_column table_name, column_name, opts
          return unless opts.present?
          
          unless disabled_validations?
            operation = operations_factory.create_operation(:add_column, table_name, column_name, opts)
            operations_list.add_operation(operation)
          end
        end

        def with_suppressed_validations
          disable_validations!
          yield
          enable_validations!
        end

        class << self
          alias_method :current, :instance

          delegate *[SUPPORTED_METHODS, :execute, :with_suppressed_validations].flatten, to: :current, allow_nil: true
        end

        private

        def disabled_validations?
          !!@disabled_validations
        end

        def disable_validations!
          @disabled_validations = true
        end

        def enable_validations!
          @disabled_validations = false
        end
      end
    end
  end
end