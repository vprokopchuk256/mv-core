require 'mv/core/db/helpers/table_validators'

module Mv
  module Core
    module Db
      module Helpers
        module ColumnValidators
          include TableValidators

          attr_accessor :column_name

          def column_validators
            table_validators.where(column_name: column_name)
          end

          def create_migration_validator validator_name, opts
            return nil unless opts.present? 

            column_validators.create!(validator_name: validator_name, options: normalize_opts(opts))
          end

          def delete_migration_validator validator_name
            column_validators.where(validator_name: validator_name).delete_all > 0
          end
          
          def update_migration_validator validator_name, opts
            return false unless opts.present? 

            column_validators.where(validator_name: validator_name).update_all(options: normalize_opts(opts)) > 0
          end

          private

          def normalize_opts opts
            opts == true ? {} : opts
          end
        end
      end
    end
  end
end