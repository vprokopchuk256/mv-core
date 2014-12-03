# module MigrationValidators
#   module ActiveRecord
#     module Migration
#       extend ActiveSupport::Concern

#       included do
#         class_eval do
#           alias_method_chain :exec_migration, :validators
#         end
#       end

#       def exec_migration_with_validators *args
#         connection.class.class_eval {
#           include MigrationValidators::ActiveRecord::ConnectionAdapters::NativeAdapter
#         } unless connection.class.include?(MigrationValidators::ActiveRecord::ConnectionAdapters::NativeAdapter)

#         connection.initialize_migration_validators_table

#         exec_migration_without_validators *args

#         MigrationValidators::Core::DbValidator.commit MigrationValidators.validator
#       end
#     end
#   end
# end
