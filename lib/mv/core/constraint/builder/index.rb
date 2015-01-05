require 'mv/core/validation/builder/factory'

module Mv
  module Core
    module Constraint
      module Builder
        class Index
          attr_reader :constraint

          delegate :name, to: :constraint

          def initialize(constraint)
            @constraint = constraint
          end

          def create
            constraint.validations.group_by(&:table_name).each do |table_name, validations|
              remove_index(table_name)
              add_index(table_name, validations.collect(&:column_name))
            end
          end

          def delete
            constraint.validations.group_by(&:table_name).each do |table_name, validations|
              remove_index(table_name)
            end
          end

          def update new_constraint
            delete
            new_constraint.create
          end

          def self.validation_builders_factory
            @validation_builders_factory ||= Mv::Core::Validation::Builder::Factory.new
          end

          private

          def validation_builders
            @validation_builders ||= constraint.validations.collect do |validation|
              self.class.validation_builders_factory.create_builder(validation)
            end
          end

          def db
            ::ActiveRecord::Base.connection
          end

          def index_exists?(table_name)
            db.index_name_exists?(table_name, name, false) 
          end

          def remove_index(table_name)
            db.remove_index!(table_name, name) if index_exists?(table_name)
          end

          def add_index(table_name, columns)
            db.add_index(table_name, columns, name: name)
          end
        end
      end
    end
  end
end