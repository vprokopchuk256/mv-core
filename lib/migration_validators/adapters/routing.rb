module MigrationValidators
  module Adapters
    module Routing
      def self.included(base)
        base.extend ClassMethods
      end

      ###################################################################
      ## UNIQUENESS
      ###################################################################
      def validate_uniqueness_index validators
        add_index validators.first
        [validators.first]
      end

      def remove_validate_uniqueness_index validators
        remove_index(validators.first)
        [validators.first]
      end

      def validate_uniqueness validators
        validate_uniqueness_index validators
      end

      def remove_validate_uniqueness validators
        remove_validate_uniqueness_index validators
      end

      private 

      def compose_index_name validator
        if validator.options.blank? || (index_name = validator.options[:index_name]).blank? 
          "idx_mgr_validates_#{validator.table_name}_#{validator.column_name}_#{validator.validator_name}"
        else
          index_name
        end
      end

      def add_index validator
        db.add_index validator.table_name, 
                     validator.column_name, 
                     :name => compose_index_name(validator),
                     :unique => true
      end

      def remove_index validator
        db.remove_index validator.table_name, 
                        :name => compose_index_name(validator)
      end

      def execute statements
        statements = [statements] if statements.kind_of?(String) 

        statements.each {|stmt| db.execute(stmt) }
      end

      module ClassMethods
        def route validator_name, container_type, opts = {}, &block
          router = MigrationValidators::Core::ValidatorRouter.new containers
          router.instance_eval(&block) if block

          default = opts.delete(:default)
          remove = opts.delete(:remove)
          remove = true if remove.nil?

          to = opts[:to]
          to = [to] unless to.kind_of?(Array)
          to.each {|container_name| router.to container_name}

          define_method :"validate_#{validator_name}_#{container_type}" do |validators|
            execute(validators.group_by(&:table_name).inject([]) do |statements, (table_name, group)|
              statements.concat(router.process(MigrationValidators::Core::DbValidator.table_validators(table_name)))
            end)
          end
          alias_method(:"validate_#{validator_name}", :"validate_#{validator_name}_#{container_type}") if default

          if remove 
            define_method :"remove_validate_#{validator_name}_#{container_type}" do |validators|
              execute(validators.group_by(&:table_name).inject([]) do |statements, (table_name, group)|
                statements.concat(router.process(MigrationValidators::Core::DbValidator.table_validators(table_name) - group))
              end)
            end
            alias_method(:"remove_validate_#{validator_name}", :"remove_validate_#{validator_name}_#{container_type}") if default
          end
        end

        def clear_routing
          public_instance_methods.grep(/^remove_validate_/) { |method_name| undef_method method_name }
          public_instance_methods.grep(/^validate_/) { |method_name| undef_method method_name }
        end

      end

    end
  end
end
