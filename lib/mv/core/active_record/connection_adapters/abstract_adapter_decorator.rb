require 'mv/core/migration/base'

module Mv
  module Core
    module ActiveRecord
      module ConnectionAdapters
        module AbstractAdapterDecorator
          def add_column table_name, column_name, type, opts
            Mv::Core::Migration::Base.add_column(table_name, column_name, opts.delete(:validates))  
            
            super 
          end

          def remove_column table_name, *column_names
            column_names.flatten.each do |column_name|
              Mv::Core::Migration::Base.remove_column table_name, column_name
            end

            super 
          end

          def rename_column table_name, old_column_name, new_column_name
            Mv::Core::Migration::Base.rename_column table_name, old_column_name, new_column_name

            super
          end

          def change_column table_name, column_name, type, opts
            Mv::Core::Migration::Base.change_column(table_name, column_name, opts.delete(:validates))

            super
          end

          def rename_table old_table_name, new_table_name
            Mv::Core::Migration::Base.rename_table(old_table_name, new_table_name)

            super
          end

          def drop_table table_name, opts = {}
            Mv::Core::Migration::Base.drop_table(table_name)

            super
          end
        end
      end
    end
  end
end