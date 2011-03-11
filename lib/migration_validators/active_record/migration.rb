module MigrationValidators
  module ActiveRecord
    module Migration
      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          class << self
            alias_method_chain :migrate, :validators
          end
        end
      end

      module ClassMethods
        def migrate_with_validators *args

          ::ActiveRecord::Base.connection.class.class_eval {
            include MigrationValidators::ActiveRecord::ConnectionAdapters::NativeAdapter
          } unless ::ActiveRecord::Base.connection.class.include?(MigrationValidators::ActiveRecord::ConnectionAdapters::NativeAdapter)

          migrate_without_validators *args
          MigrationValidators::Core::DbValidator.commit MigrationValidators.validator
        end
      end
    end
  end
end
