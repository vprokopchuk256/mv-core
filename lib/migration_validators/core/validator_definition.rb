module MigrationValidators
  module Core
    class ValidatorDefinition < StatementBuilder
      attr_reader :validator

      def initialize definition = nil, validator = nil, properties = {}, posts = []
        super "", definition

        @properties = properties
        @posts = posts

        self.validator = validator if validator

        operation :bind_to_error do |stmt, error|
          stmt
        end
      end

      def validator= validator
        @validator = validator
        @stmt = validator.column_name
      end

      def column
        clone
      end

      def clone builder = nil
        res = ValidatorDefinition.new self, validator, @properties.clone, @posts.clone
        res.merge!(builder) if builder
        res
      end

      def property name = "", opts = {}, &block
        @properties[name.to_s] ||= [opts, block]
      end

      def post opts = {}, &block
        @posts << [opts, block]
      end

      def process validator, filter = []
        self.validator = validator

        return [] if validator.options.nil?

        unless filter.blank? 
          filter = filter.collect(&:to_s)
          options = validator.options.select{|name, value| filter.include?(name.to_s) }
        else
          options = validator.options
        end

        res = options.inject([]) do |res, (property_name, property_value)|
          res << self.to_s if handle_property(property_name, property_value)
          res
        end

        return res unless res.blank?
        return (handle_property("", options) && res << self.to_s) || []
      end

      private 

      def handle_property property_name, property_value
          opts, block = @properties[property_name.to_s]

          if (block)
            at_least_one_property_handled = true
            change(property_value, &block)
            apply_posts
            bind_to_error(message(opts))

            return true
          end

          false
      end

      def apply_posts 
        @posts.each{|opts, post_block| change(&post_block) if validator.satisfies(opts)}
      end

      def message opts
        validator.options[opts[:message]] || 
        validator.options[:message] ||
        validator.error_message
      end
    end
  end
end
