# module MigrationValidators
#   module ActiveRecord
#     module Schema
#       extend ActiveSupport::Concern

#       included do
#         class_eval do
#           class << self
#             alias_method_chain :define, :validators
#           end
#         end
#       end

#       module ClassMethods
#         def define_with_validators *args, &block

#           connection.class.class_eval {
#             include MigrationValidators::ActiveRecord::ConnectionAdapters::NativeAdapter
#           } unless connection.class.include?(MigrationValidators::ActiveRecord::ConnectionAdapters::NativeAdapter)

#           connection.initialize_migration_validators_table

#           res = define_without_validators *args, &block

#           MigrationValidators::Core::DbValidator.commit MigrationValidators.validator

#           res
#         end
#       end
#     end
#   end
# end
