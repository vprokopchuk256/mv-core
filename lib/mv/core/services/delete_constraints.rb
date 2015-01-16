require 'mv/core/services/load_constraints'

module Mv
  module Core
    module Services
      class DeleteConstraints
        attr_reader :tables

        def initialize(tables = [])
          @tables = tables.present? ? tables : Mv::Core::Db::MigrationValidator.pluck(:table_name)
        end

        def execute
          constraints_comparizon = Mv::Core::Services::CompareConstraintArrays.new(existing_constraints, [])
                                                                              .execute
          Mv::Core::Services::SynchronizeConstraints.new(constraints_comparizon[:added], 
                                                         constraints_comparizon[:updated], 
                                                         constraints_comparizon[:deleted])
                                                    .execute
        end

        private

        def existing_constraints
          Mv::Core::Services::LoadConstraints.new(tables).execute
        end
      end
    end
  end
end