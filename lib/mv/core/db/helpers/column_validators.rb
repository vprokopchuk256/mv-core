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

          def create_column_validator validation_type, opts
            raise_column_validation_error(validation_type, opts) if opts == false

            update_column_validator(validation_type, opts)
          end

          def delete_column_validator 
            delete_validators(column_validators) > 0
          end
          
          def update_column_validator validation_type, opts
            return delete_validators(column_validators.where(validation_type: validation_type)) if opts == false

            column_validators.where(validation_type: validation_type).first_or_initialize.tap do |validator|
              validator.options = normalize_opts(opts)
              say(Mv::Core::Presenter::MigrationValidator.new(validator).to_s)
            end.save!
          end

          def rename_column new_column_name
            column_validators.update_all(column_name: new_column_name)
          end

          private

          def normalize_opts opts
            opts == true ? {} : opts
          end

          def raise_column_validation_error validation_type, opts
            raise Mv::Core::Error.new(
              table_name: table_name, 
              column_name: column_name, 
              validation_type: validation_type, 
              options: opts,
              error: 'Validator can not be removed when new column is being added'
            )
          end
        end
      end
    end
  end
end