module MigrationValidators
  module Adapters
    class Base
      class << self
        def validators
          @validators ||= {}
        end

        def containers to = nil
          @containers ||= {}

          return @containers unless to

          to = [to] unless to.kind_of?(Array)
        
          @containers.select {|container_name, container_value| to.include?(container_name)}
        end

        def builder &block
          @builder ||= MigrationValidators::Core::StatementBuilder.new

          @builder.instance_eval(&block) if block
        end

        def validator name, &block
          validator = MigrationValidators::Core::ValidatorDefinition.new(builder)
          validator.instance_eval(&block) if block

          validators[name] = validator
        end

        def container name, &block
          container = MigrationValidators::Core::ValidatorContainer.new(validators, builder)
          container.instance_eval(&block) if block

          containers[name] = container
        end

        def route validator_name, container_type, opts = {}, &block
          router = MigrationValidators::Core::ValidatorRouter.new containers
          router.instance_eval(&block) if block

          default = opts.delete(:default)
          remove = opts.delete(:remove) || true

          define_method :"validate_#{validator_name}_#{container_type}" do |validators|
            table_name = validators.first.table_name
            table_validators = MigrationValidators::Core::DbValidator.table_validators(table_name)

            execute(router.process(table_validators))
          end
          alias_method(:"validate_#{validator_name}", :"validate_#{validator_name}_#{container_type}") if default

          if remove 
            define_method :"remove_validate_#{validator_name}_#{container_type}" do |validators|
              table_name = validators.first.table_name
              validators_to_restore = MigrationValidators::Core::DbValidator.table_validators(table_name) - validators

              execute(router.process(validators_to_restore))
            end
            alias_method(:"remove_validate_#{validator_name}", :"remove_validate_#{validator_name}_#{container_type}") if default
          end
        end

        private 

        def execute statements
          statements = [statements] if statements.kind_of?(String) 

          statements.each {|stmt| db.execute(stmt) }
        end
      end
    end
  end
end
