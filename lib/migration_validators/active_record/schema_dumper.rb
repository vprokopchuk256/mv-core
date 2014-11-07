module MigrationValidators
  module ActiveRecord
    module SchemaDumper
      extend ActiveSupport::Concern

      included do
        class_eval do
          alias_method_chain :tables, :validators
        end
      end

      def tables_with_validators(stream)
        tables_without_validators(stream)

        @connection.initialize_migration_validators_table

        stream.puts ""
        stream.puts "  #Validators"
        MigrationValidators::Core::DbValidator.order([:table_name, :column_name]).each do |validator|
          stream.puts "  validate_column :#{validator.table_name}, :#{validator.column_name}, :#{validator.validator_name} => #{validator.options.inspect}"
        end
      end
    end
  end
end
