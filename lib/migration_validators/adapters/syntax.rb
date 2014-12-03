# module MigrationValidators
#   module Adapters
#     module Syntax
#       extend ActiveSupport::Concern

#       module ClassMethods
#         def define_base_syntax
#           syntax do
#             operation(:db_name)
#             operation(:db_value)
#             operation(:wrap) {|value| "(#{value})"}
#             operation(:and) {|stmt, value| "#{stmt} AND #{value}"}
#             operation(:or) {|stmt, value| "#{stmt} OR #{value}"}
#             operation(:length) {|value| "LENGTH(#{stmt})"}
#             operation(:trim) {|value| "TRIM(#{stmt})"}
#             operation(:coalesce) {|value| "COALESCE(#{stmt}, '')"}
#             operation(:if) {|if_stmt, then_stmt| "IF #{if_stmt} THEN #{then_stmt} ENDIF"}
#             operation(:regexp) {|stmt, value| "#{stmt} REGEXP #{value}"}
#             operation(:greater_than) {|stmt, value| "#{stmt} > #{value}"}
#             operation(:greater_or_equal_to) {|stmt, value| "#{stmt} >= #{value}"}
#             operation(:less_than) {|stmt, value| "#{stmt} < #{value}"}
#             operation(:less_or_equal_to) {|stmt, value| "#{stmt} <= #{value}"}
#             operation(:equal_to) {|stmt, value| "#{stmt} = #{value}"}
#             operation(:between) do |stmt, range| 
#               "#{@stmt} >= #{compile(range.first).db_value} AND #{@stmt} <#{range.exclude_end? ? '' : '='} #{compile(range.last).db_value}"
#             end
#             operation(:in) do |stmt, array| 
#               "#{@stmt} IN (#{array.collect{|value| compile(value).db_value}.join(', ')})"
#             end
#             operation(:not_in) do |stmt, array| 
#               "#{@stmt} NOT IN (#{array.collect{|value| compile(value).db_value}.join(', ')})"
#             end
#             operation(:not_null) {|value| "#{value} IS NOT NULL"}
#             operation(:null) {|value| "#{value} IS NULL"}
#             operation(:not) {|value| "NOT #{value}"}
#             operation(:exists) {|value| "EXISTS #{value}"}
#             operation(:select) {|value| "SELECT #{value}"}
#             operation(:from) {|value| " FROM #{value}"}
#             operation(:where) {|value| "WHERE #{value}"}
#           end
#         end

#         def syntax &block
#           @builder ||= MigrationValidators::Core::StatementBuilder.new
#           @builder.instance_eval(&block) if block
#           @builder
#         end
#       end
#     end
#   end
# end
