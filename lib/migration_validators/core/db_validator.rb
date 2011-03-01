module MigrationValidators
  module Core
    class DbValidator < ::ActiveRecord::Base
      set_table_name MigrationValidators.migration_validators_table_name

      validates :table_name,  :presence => true,   
                              :length => {:maximum => 255 }

      validates :column_name,  :length => {:maximum => 255 }

      validates :validator_name,  :presence => true,  
                                  :length => {:maximum => 255 }

      validate do |validator|
        unless ::ActiveRecord::Base.connection.table_exists?(validator.table_name)
          validator.errors[:table_name] << "table '#{table_name}' does not exist" 
        else 
          unless ::ActiveRecord::Base.connection.columns(validator.table_name).any?{|col| col.name == column_name.to_s}
            validator.errors[:column_name] << "column '#{column_name}' does not exist in the table '#{table_name}'" 
          end
        end
      end 

      serialize :options, Hash

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

      class << self 

        def add_column_validator table_name, column_name, validator_name, opts
          remove_validators(:table_name => table_name,
                            :column_name => column_name,
                            :validator_name => validator_name)

          add_new_validator(:table_name => table_name,
                            :column_name => column_name,
                            :validator_name => validator_name, 
                            :options => opts)
        end

        def remove_column_validator table_name, column_name, validator_name
          remove_validators :table_name => table_name, :column_name => column_name, :validator_name => validator_name
        end

        def remove_column_validators table_name, column_name
          remove_validators :table_name => table_name, :column_name => column_name
        end

        def table_validators table_name, opts = {}
          with_options opts do
            DbValidator.find(:all, :conditions => { :table_name => table_name })
          end
        end

        def remove_table_validators table_name 
          remove_validators :table_name => table_name
        end
        
        def column_validators table_name, column_name, opts = {}
          with_options opts do
            DbValidator.find :all, :conditions => { :table_name => table_name, :column_name => column_name }
          end
        end

        def rename_column table_name, old_column_name, new_column_name
          DbValidator.update_all({:column_name => new_column_name}, :column_name => old_column_name)
        end

        def rename_table old_table_name, new_table_name
          DbValidator.update_all({:table_name => new_table_name}, :table_name => old_table_name)
        end

        def commit adapter = nil
          adapter.remove_validators(validators_to_remove) if adapter
          validators_to_remove.each(&:destroy) 
          validators_to_remove.clear

          validators_to_add.each(&:save!)
          adapter.create_validators(validators_to_add) if adapter
          validators_to_add.clear
        end

        def rollback
          validators_to_remove.clear
          validators_to_add.clear
        end


        private 

        def with_options opts, &block
          block.call.select {|validator| validator.satisfies(opts) } 
        end

        def add_new_validator opts
          validators_to_add << new(opts)
        end

        def remove_validators opts
          DbValidator.find(:all, :conditions => opts).each { |validator| validators_to_remove << validator }
        end

        def validators_to_remove
          @validators_to_remove ||= []
        end

        def validators_to_add
          @validators_to_add ||= []
        end

      end
    end
  end
end
