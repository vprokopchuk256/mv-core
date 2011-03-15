module MigrationValidators
  module ActiveRecord
    module ConnectionAdapters 
      module NativeAdapter 
        def self.included(base)
          base.class_eval do
            alias_method_chain :drop_table, :validators
            alias_method_chain :remove_column, :validators
            alias_method_chain :rename_column, :validators
            alias_method_chain :change_column, :validators
            alias_method_chain :add_column, :validators
            alias_method_chain :rename_table, :validators
            alias_method_chain :create_table, :validators
          end
        end

        def validate_column table_name, column_name, opts
          table_name = table_name || @context_table_name
          raise MigrationValidatorsException.new("at least one column validator should be defined") if opts.blank?
          

          opts.each do |validator_name, validator_options|
            if validator_options.blank?
              raise MigrationValidatorsException.new("use false to remove column validator") unless validator_options == false

              MigrationValidators::Core::DbValidator.remove_column_validator table_name, column_name, validator_name
            else 
              validator_options = {} if validator_options == true
              MigrationValidators::Core::DbValidator.add_column_validator table_name, column_name, validator_name, validator_options
            end
          end
        end

        def in_context_of_table table_name
          @context_table_name = table_name
          res = yield if block_given?
          @context_table_name = nil
          res
        end

        def do_internally
          disable_migration_validators
          yield
          enable_migration_validators
        end

        private

        def disable_migration_validators
          @migration_validators_call_stack = [0, @migration_validators_call_stack ||= 0].max + 1
        end

        def enable_migration_validators
          @migration_validators_call_stack = [0, @migration_validators_call_stack ||= 0].max - 1
        end

        def migration_validators_enabled
          (@migration_validators_call_stack ||= 0) <= 0
        end


        def do_enabled
          yield if migration_validators_enabled
        end


        def drop_table_with_validators table_name
          do_enabled { MigrationValidators::Core::DbValidator.remove_table_validators table_name }
          do_internally { drop_table_without_validators table_name }
        end

        def remove_column_with_validators table_name, *column_names
          do_enabled do
            column_names.flatten.each do |column_name| 
              MigrationValidators::Core::DbValidator.remove_column_validators table_name, column_name 
            end
          end

          do_internally { remove_column_without_validators table_name, *column_names }
        end

        def rename_column_with_validators table_name, old_column_name, new_column_name
          do_enabled { MigrationValidators::Core::DbValidator.rename_column table_name, old_column_name, new_column_name }
          do_internally { rename_column_without_validators table_name, old_column_name, new_column_name }
        end

        def add_column_with_validators table_name, column_name, type, opts
          validates = opts.delete(:validates)

          do_internally { add_column_without_validators table_name, column_name, type, opts }

          do_enabled { validate_column(table_name, column_name, validates) } unless validates.blank?
        end

        def rename_table_with_validators old_table_name, new_table_name
          do_enabled { MigrationValidators::Core::DbValidator.rename_table old_table_name, new_table_name }
          do_internally { rename_table_without_validators old_table_name, new_table_name }
        end

        def change_column_with_validators table_name, column_name, type, opts
          validates = opts.delete(:validates)

          do_enabled { MigrationValidators::Core::DbValidator.remove_column_validators table_name, column_name }

          do_internally { change_column_without_validators table_name, column_name, type, opts }

          do_enabled { validate_column(table_name, column_name, validates) } unless validates.blank?
        end

        def create_table_with_validators table_name, *args, &block
          in_context_of_table table_name do
            create_table_without_validators table_name, *args, &block
          end
       end
      end
    end
  end
end
