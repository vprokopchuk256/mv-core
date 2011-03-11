module MigrationValidators
  module ActiveRecord
    module SchemaDumper
      def self.included(base)
        base.class_eval do
          alias_method_chain :tables, :validators
        end
      end

      def tables_with_validators(stream)
        tables_without_validators(stream)

        stream.puts ""
        stream.puts "  #Validators"
        MigrationValidators::Core::DbValidator.find(:all, :order => "table_name, column_name").each do |validator|
          stream.puts "  validate_column :#{validator.table_name}, :#{validator.column_name}, :#{validator.validator_name} => #{validator.options.inspect}"
        end
      end

      private 
        
    end
  end
end
