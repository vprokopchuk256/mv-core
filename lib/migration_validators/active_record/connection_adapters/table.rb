module MigrationValidators
  module ActiveRecord
    module ConnectionAdapters
      module Table
        def self.included(base)
          base.class_eval do
            def change_validates column_name, opts
              ::ActiveRecord::Base.connection.validate_column(@table_name, column_name, opts) unless opts.blank?
            end
          end
        end
      end
    end
  end
end
