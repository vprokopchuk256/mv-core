module MigrationValidators
  module ActiveRecord
    module SchemaDumper
      def self.included(base)
        base.class_eval do
          alias_method_chain :dump, :validators
        end
      end

      def dump_with_validators(stream)
        dump_without_validators(stream)

        stream.puts ""
        stream.puts "#Validators"
        stream.puts ""
        MigrationValidators::Core::DbValidator.find(:all, :order => "table_name, column_name").each do |validator|
          stream.puts "validate_column :#{validator.table_name}, :#{validator.column_name}, :#{validator.validator_name} => #{validator.options.inspect}"
        end
      end

      private 
        
    end
  end
end
