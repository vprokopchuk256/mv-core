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

          def create_column_validator validator_name, opts
            raise_column_validation_error(validator_name, opts) if opts == false

            column_validators.where(validator_name: validator_name).first_or_initialize.tap do |validator|
              validator.options = normalize_opts(opts)
            end.save!
          end

          def delete_column_validator validator_name
            column_validators.where(validator_name: validator_name).delete_all > 0
          end
          
          def update_column_validator validator_name, opts
            return false unless opts.present? 

            column_validators.where(validator_name: validator_name).update_all(options: normalize_opts(opts)) > 0
          end

          private

          def normalize_opts opts
            opts == true ? {} : opts
          end

          def raise_column_validation_error validator_name, opts
            raise Mv::Core::Error.new(
              table_name: table_name, 
              column_name: column_name, 
              validator_name: validator_name, 
              options: opts,
              error: 'Validator can not be removed when new column is being added'
            )
          end
        end
      end
    end
  end
end