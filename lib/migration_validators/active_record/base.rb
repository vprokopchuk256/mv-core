# module MigrationValidators
#   module ActiveRecord
#     module Base
#       extend ActiveSupport::Concern

#       included do
#         class_eval do
#           class << self
#             alias_method_chain :establish_connection, :validators
#           end
#         end
#       end

#       module ClassMethods
#         def establish_connection_with_validators *args
#           establish_connection_without_validators *args

#           connection.class.class_eval {
#             include MigrationValidators::ActiveRecord::ConnectionAdapters::NativeAdapter
#           } unless connection.class.include?(MigrationValidators::ActiveRecord::ConnectionAdapters::NativeAdapter)

#           connection.class.class_eval {
#             include MigrationValidators::ActiveRecord::ConnectionAdapters::AbstractAdapter
#           } unless connection.class.include?(MigrationValidators::ActiveRecord::ConnectionAdapters::AbstractAdapter)
#         end
#       end
#     end
#   end
# end
