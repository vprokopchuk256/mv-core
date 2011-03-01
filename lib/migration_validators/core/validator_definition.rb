module MigrationValidators
  module Core
    class ValidatorDefinition < StatementBuilder
      attr_reader :validator

      def initialize definition = nil, validator = nil, properties = {}
        super "", definition

        @properties = properties

        self.validator = validator if validator

        action :column_name do |stmt|
          self.validator.column_name
        end

        action :bind_to_error do |stmt, error|
          stmt
        end
      end

      def validator= validator
        @validator = validator
        column_name(validator.column_name)
      end

      def column
        clone
      end

      def clone builder = nil
        res = ValidatorDefinition.new self, validator, @properties.clone
        res.merge!(builder) if builder
        res
      end

      def property name, opts = {}, &block
        @properties[name.to_s] ||= [opts, block]
      end

      def process validator, filter = []
        self.validator = validator

        return [] if validator.options.blank?

        unless filter.blank? 
          filter = filter.collect(&:to_s)
          options = validator.options.select{|name, value| filter.include?(name.to_s) }
        else
          options = validator.options
        end

        options.inject([]) do |res, (property_name, property_value)|
          opts, block = @properties[property_name.to_s]
          
          if (block)
            change(property_value, &block)
            bind_to_error(message(opts))
          
            res << self.to_s
          end

          res
        end unless validator.options.blank?
      end

      private 

      def message opts
        validator.options[opts[:message]] || 
        validator.options[:message] ||
        validator.error_message
      end
    end
  end
end
