module MigrationValidators
  module Core
    class DbValidator < ::ActiveRecord::Base
      @@validators_to_remove = []
      @@validators_to_add = []


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
      serialize :constraints, ValidatorConstraintsList

      scope :on_table, -> (table_name) { where table_name: table_name }
      scope :on_column, -> (column_name) { where column_name: column_name }
      scope :with_name, -> (validator_name) { where validator_name: validator_name }

      def options
        attributes['options'] ||= {}
      end

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
          [property_name, [property_value].flatten]
        end.all? do |property_name, property_value| 
          property_value.include?(options[property_name])
        end
      end

      def delayed_destroy 
        @@validators_to_remove << self unless @@validators_to_remove.include?(self)
      end

      def delayed_save
        DbValidator.on_table(table_name)
                   .on_column(column_name)
                   .with_name(validator_name)
                   .delayed_destroy
                   
        @@validators_to_add << self unless @@validators_to_add.include?(self)
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

      def satisfies opts
        all.select{|validator| validator.satisfies(opts) }
      end

      def delayed_destroy
        all.each(&:delayed_destroy)
      end

      def constraint_validators constraint
        (DbValidator.where("constraints LIKE ?", "%#{constraint}%").all + @@validators_to_add - @@validators_to_remove).select{|validator| validator.constraints.include?(constraint)}
      end

      def rename_column table_name, old_column_name, new_column_name
        all.on_table(table_name).on_column(old_column_name).update_all(column_name: new_column_name)
      end

      def rename_table old_table_name, new_table_name
        all.on_table(old_table_name).update_all(table_name: new_table_name)
      end

      def commit adapter = nil
        adapter.remove_validators(@@validators_to_remove.select{|validator| ::ActiveRecord::Base.connection.table_exists?(validator.table_name)}) if adapter
        @@validators_to_remove.each(&:destroy) 
        @@validators_to_remove.clear

        adapter.create_validators(@@validators_to_add) if adapter
        @@validators_to_add.each(&:save!)
        @@validators_to_add.clear
      end

      def rollback
        @@validators_to_remove.clear
        @@validators_to_add.clear
      end

      def clear_all
        rollback
        DbValidator.delete_all
      end

      end
    end
  end
end
