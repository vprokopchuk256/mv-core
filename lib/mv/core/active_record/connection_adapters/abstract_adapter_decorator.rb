require 'mv/core/migration/base'
require 'mv/core/services/parse_validation_options'

module Mv
  module Core
    module ActiveRecord
      module ConnectionAdapters
        module AbstractAdapterDecorator
          def add_column table_name, column_name, type, opts = {}
            Mv::Core::Migration::Base.add_column(table_name, column_name, params(opts))

            super
          end

          def remove_column table_name, column_name, type = nil, options = {}
            Mv::Core::Migration::Base.remove_column table_name, column_name

            super
          end

          def rename_column table_name, old_column_name, new_column_name
            Mv::Core::Migration::Base.rename_column table_name, old_column_name, new_column_name

            super
          end

          def change_column table_name, column_name, type, opts = {}
            Mv::Core::Migration::Base.change_column(table_name, column_name, params(opts))

            super
          end

          def validates table_name, column_name, opts
            Mv::Core::Migration::Base.change_column(table_name, column_name, opts)
          end

          def rename_table old_table_name, new_table_name
            Mv::Core::Migration::Base.rename_table(old_table_name, new_table_name)

            super
          end

          def drop_table table_name, opts = {}
            Mv::Core::Migration::Base.drop_table(table_name)

            super
          end

          private

          def params opts
            Mv::Core::Services::ParseValidationOptions.new(opts).execute
          end
        end
      end
    end
  end
end
