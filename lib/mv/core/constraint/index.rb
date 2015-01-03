require 'mv/core/constraint/base'

module Mv
  module Core
    module Constraint
      class Index < Base
        def initialize description
          super
        end
        
        def create
          validations.group_by(&:table_name).each do |table_name, validations|
            remove_index(table_name)
            add_index(table_name, validations.collect(&:column_name))
          end
        end

        def delete
          validations.group_by(&:table_name).each do |table_name, validations|
            remove_index(table_name)
          end
        end

        def update new_constraint
          delete
          new_constraint.create
        end

        private

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