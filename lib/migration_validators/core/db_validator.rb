module MigrationValidators
  module Core
    class DbValidator < ::ActiveRecord::Base
      self.table_name = MigrationValidators.migration_validators_table_name

      validates_presence_of :table_name
      validates_length_of :table_name, :maximum => 255
      validates_length_of :column_name, :maximum => 255

      validates_presence_of :validator_name
      validates_length_of :validator_name, :maximum => 255

      validate do |validator|
        unless ::ActiveRecord::Base.connection.table_exists?(validator.table_name)
          validator.errors[:table_name] << "table '#{table_name}' does not exist" 
        else 
          unless ::ActiveRecord::Base.connection.columns(validator.table_name).any?{|col| col.name == validator.column_name.to_s}
            validator.errors[:column_name] << "column '#{column_name}' does not exist in the table '#{table_name}'" 
          end
        end
      end 

      before_save :prepare_options

      serialize :options, Hash
      serialize :constraints, Array

      def name
        "#{table_name}_#{column_name}_#{validator_name}"
      end


      def error_message
        unless (options.blank? || (message = options[:message]).blank?)
          message
        else
          "#{validator_name} violated for #{table_name} field #{column_name}"
        end
      end

      def satisfies opts
        return true if opts.blank?

        opts.collect do |property_name, property_value| 
          [property_name, property_value.kind_of?(Array) ? property_value : [property_value]]
        end.all? do |property_name, property_value| 
          property_value.include?(options[property_name])
        end
      end

      def save_to_constraint constraint_name
        self.constraints ||= []
        self.constraints << constraint_name.to_s unless self.constraints.include?(constraint_name.to_s)
      end

      def remove_from_constraint constraint_name
        self.constraints.delete(constraint_name.to_s) if self.constraints
      end

      def in_constraint? constraint_name
        self.constraints && self.constraints.include?(constraint_name.to_s)
      end

      private
        def prepare_options
          options = options.inject({}) do |res, (key, value)|
            res[key.to_s] = value
            res
          end unless options.blank?

          true
        end

      class << self 

        def add_column_validator table_name, column_name, validator_name, opts
          remove_validators(:table_name => table_name.to_s,
                            :column_name => column_name.to_s,
                            :validator_name => validator_name.to_s)

          add_new_validator(:table_name => table_name.to_s,
                            :column_name => column_name.to_s,
                            :validator_name => validator_name.to_s, 
                            :options => opts)
        end

        def remove_column_validator table_name, column_name, validator_name
          remove_validators :table_name => table_name.to_s, :column_name => column_name.to_s, :validator_name => validator_name.to_s
        end

        def remove_column_validators table_name, column_name
          remove_validators :table_name => table_name.to_s, :column_name => column_name.to_s
        end

        def table_validators table_name, opts = {}
          with_options opts do
            DbValidator.find(:all, :conditions => { :table_name => table_name.to_s })
          end
        end

        def constraint_validators constraint
          (DbValidator.find(:all, :conditions => ["constraints LIKE ?", "%#{constraint}%"]) + validators_to_add - validators_to_remove).select{|validator| validator.in_constraint?(constraint)}
        end

        def remove_table_validators table_name 
          remove_validators :table_name => table_name.to_s
        end
        
        def column_validators table_name, column_name, opts = {}
          with_options opts do
            DbValidator.find :all, :conditions => { :table_name => table_name.to_s, :column_name => column_name.to_s }
          end
        end

        def rename_column table_name, old_column_name, new_column_name
          DbValidator.update_all({:column_name => new_column_name.to_s}, :column_name => old_column_name.to_s)
        end

        def rename_table old_table_name, new_table_name
          DbValidator.update_all({:table_name => new_table_name.to_s}, :table_name => old_table_name.to_s)
        end

        def commit adapter = nil
          adapter.remove_validators(validators_to_remove.select{|validator| ::ActiveRecord::Base.connection.table_exists?(validator.table_name)}) if adapter
          validators_to_remove.each(&:destroy) 
          validators_to_remove.clear

          adapter.create_validators(validators_to_add) if adapter
          validators_to_add.each(&:save!)
          validators_to_add.clear
        end

        def rollback
          validators_to_remove.clear
          validators_to_add.clear
        end


        def clear_all
          rollback
          DbValidator.delete_all
        end

        def validators_to_remove
          @validators_to_remove ||= []
        end

        def validators_to_add
          @validators_to_add ||= []
        end

        private 

        def validators_to_remove
          @validators_to_remove ||= []
        end

        def validators_to_add
          @validators_to_add ||= []
        end

        def with_options opts, &block
          block.call.select {|validator| validator.satisfies(opts) } 
        end

        def add_new_validator opts
          validators_to_add << new(opts)
        end

        def remove_validators opts
          DbValidator.find(:all, :conditions => opts).each { |validator| validators_to_remove << validator }
        end


      end
    end
  end
end
