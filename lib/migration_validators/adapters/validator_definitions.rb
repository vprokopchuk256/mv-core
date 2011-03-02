module MigrationValidators
  module Adapters
    module ValidatorDefinitions
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def validators
          @validators ||= {}
        end

        def validator name, opts = {}, &block
          validator = validators[name] ||= MigrationValidators::Core::ValidatorDefinition.new(syntax)

          validator.post :allow_nil => true do
            self.wrap.or(column.db_name.not_null)
          end if opts[:allow_nil] || !opts.key?(:allow_nil)

          validator.post :allow_blank => true do
            self.wrap.or(column.db_name.trim.length.equal_to(0))
          end if opts[:allow_blank] || !opts.key?(:allow_blank)

          validator.instance_eval(&block) if block
        end
      end
    end
  end
end
