module MigrationValidators
  module ActiveRecord
    module ConnectionAdapters
      module TableDefinition
        extend ActiveSupport::Concern

        included do
          class_eval do
            alias_method_chain :column, :validators

            def change_validates *args
            end
          end
        end

        module InstanceMethods 
          def column_with_validators name, type, options = {}
            validates = options.delete(:validates)

            column_without_validators name, type, options

            ::ActiveRecord::Base.connection.validate_column(nil, name, validates) unless validates.blank?
          end
        end
      end
    end
  end
end
