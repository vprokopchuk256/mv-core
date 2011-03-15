module MigrationValidators
  module ActiveRecord
    module Migrator
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          class << self
            alias_method_chain :rollback, :validators
          end
        end
      end

      module ClassMethods
        def rollback_with_validators *args, &block

          res = rollback_without_validators *args, &block

          MigrationValidators::Core::DbValidator.commit MigrationValidators.validator

          res
        end
      end
    end
  end
end
