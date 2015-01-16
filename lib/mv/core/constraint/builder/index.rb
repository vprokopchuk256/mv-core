require 'mv/core/constraint/builder/base'

module Mv
  module Core
    module Constraint
      module Builder
        class Index < Base
          def create
            super

            constraint.validations.group_by(&:table_name).each do |table_name, validations|
              remove_index(table_name)
              add_index(table_name, validations.collect(&:column_name))
            end
          end

          def delete
            super 

            constraint.validations.group_by(&:table_name).each do |table_name, validations|
              remove_index(table_name)
            end
          end

          def update new_constraint_builder
            super 

            delete
            new_constraint_builder.create
          end

          private

          def index_exists?(table_name)
            db.table_exists?(table_name) && 
            db.index_name_exists?(table_name, name, false) 
          end

          def remove_index(table_name)
            db.remove_index!(table_name, name) if index_exists?(table_name)
          end

          def add_index(table_name, columns)
            db.add_index(table_name, columns, name: name, unique: true)
          end
        end
      end
    end
  end
end