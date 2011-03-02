require File.expand_path(File.dirname(__FILE__)) + '/syntax'
require File.expand_path(File.dirname(__FILE__)) + '/validator_definitions'
require File.expand_path(File.dirname(__FILE__)) + '/containers'
require File.expand_path(File.dirname(__FILE__)) + '/routing'

module MigrationValidators
  module Adapters
    class Base
      include MigrationValidators::Adapters::Syntax
      include MigrationValidators::Adapters::ValidatorDefinitions
      include MigrationValidators::Adapters::Containers
      include MigrationValidators::Adapters::Routing

      syntax do
        operation(:db_name)
        operation(:db_value)
        operation(:wrap) {|value| "#{value}"}
        operation(:and) {|stmt, value| "#{stmt} AND #{value}"}
        operation(:or) {|stmt, value| "#{stmt} OR #{value}"}
        operation(:length) {|value| "LENGTH(#{stmt})"}
        operation(:trim) {|value| "TRIM(#{stmt})"}
        operation(:coalesce) {|value| "COALESCE(#{stmt}, '')"}
        operation(:if) {|if_stmt, then_stmt| "IF #{if_stmt} THEN #{then_stmt} ENDIF"}
        operation(:regexp) {|stmt, value| "#{stmt} REGEXP #{value}"}
        operation(:greater_than) {|stmt, value| "#{stmt} > #{value}"}
        operation(:greater_or_equal_to) {|stmt, value| "#{stmt} >= #{value}"}
        operation(:less_than) {|stmt, value| "#{stmt} < #{value}"}
        operation(:less_or_equal_to) {|stmt, value| "#{stmt} <= #{value}"}
        operation(:equal_to) {|stmt, value| "#{stmt} = #{value}"}
        operation(:between) do |stmt, range| 
          "#{@stmt} >= #{compile(range.first).db_value} AND #{@stmt} <#{range.exclude_end? ? '' : '='} #{compile(range.last).db_value}"
        end
        operation(:in) do |stmt, range| 
          "#{@stmt} IN (#{array.collect{|value| compile(value).db_value}.join(', ')})"
        end
        operation(:not_in) do |stmt, range| 
          "#{@stmt} NOT IN (#{array.collect{|value| compile(value).db_value}.join(', ')})"
        end
        operation(:not_null) {|value| "#{value} IS NOT NULL"}
        operation(:not) {|value| "NOT #{value}"}
        operation(:exists) {|value| "EXISTS #{value}"}
        operation(:select) {|value| "SELECT #{value}"}
        operation(:from) {|value| " FROM #{value}"}
        operation(:where) {|value| "WHERE #{value}"}
      end

      validator :inclusion  do
        property :in do |value|
          case value.class.name 
            when "Array" then column.db_name.not_null.and(column.db_name.in(value))
            when "Range" then column.db_name.not_null.and(db_name.between(value))
            else column.db_name.not_null.and(column.db_name.between(compile(value).db_value))
          end
        end
      end

      validator :exclusion  do
        property :in do |value|
          case value.class.name 
            when "Array" then column.db_name.not_null.and(column.db_name.not_in(value))
            when "Range" then column.db_name.not_null.and(column.db_name.between(value).wrap.not)
            else column.db_name.not_null.and(column.db_name.equal_to(compile(value).db_value).wrap.not)
          end
        end
      end

      validator :format  do
        property :in do |value| 
          column.db_name.not_null.and(column.db_name.regexp(compile(value).db_value))
        end
      end

      validator :length  do
        property :is, :message => :wrong_length do |value| 
          column.db_name.length.equal_to(compile(value).db_value) 
        end
        property :maximum, :message => :too_long do |value| 
          column.db_name.length.less_or_equal_to(compile(value).db_value) 
        end
        property :minimum, :message => :too_short do |value| 
          column.db_name.length.greater_or_equal_to(compile(value).db_value) 
        end

        property :in do |value|
          case value.class.name 
            when "Array" then column.db_name.length.in(value)
            when "Range" then column.db_name.length.between(value)
            else column.db_name.length.equal_to(compile(value).db_value)
          end
        end

        property :within do |value|
          case value.class.name 
            when "Array" then column.db_name.length.in(value)
            when "Range" then column.db_name.length.between(value)
            else column.db_name.length.equal_to(compile(value).db_value)
          end
        end
      end

      validator :size  do
        property :is, :message => :wrong_length do |value| 
          column.db_name.length.equal_to(compile(value).db_value) 
        end
        property :maximum, :message => :too_long do |value| 
          column.db_name.length.less_or_equal_to(compile(value).db_value) 
        end
        property :minimum, :message => :too_short do |value| 
          column.db_name.length.greater_or_equal_to(compile(value).db_value) 
        end

        property :in do |value|
          case value.class.name 
            when "Array" then column.db_name.length.in(value)
            when "Range" then column.db_name.length.between(value)
            else column.db_name.length.equal_to(compile(value).db_value)
          end
        end

        property :within do |value|
          case value.class.name 
            when "Array" then column.db_name.length.in(value)
            when "Range" then column.db_name.length.between(value)
            else column.db_name.length.equal_to(compile(value).db_value)
          end
        end
      end

      validator :presense  do
        property do |value| 
          column.db_name.not_null.and(column.db_name.trim.length.grater_than(0))
        end
      end

      validator :uniqueness do
        property do |value|
          column.db_name.select.from(validator.table_name).where(column.db_name.equal_to(column.coalesce)).wrap.exists.not
        end
      end

      container :insert_trigger do
        group do |validator|
          [validator.table_name, "trg_mgr_validates_#{validator.table_name}_ins"]
        end

        operation :create do |stmt, group_name|
          table_name, trigger_name = group_name

          "CREATE TRIGGER #{trigger_name} BEFORE INSERT ON #{table_name} FOR EACH ROW
           BEGIN
            #{stmt}
           END;"
        end

        operation :drop do |stmt, group_name|
          table_name, trigger_name = group_name

          "DROP TRIGGER IF EXISTS #{trigger_name};"
        end

        operation :join do |stmt, value|
          [stmt, value].delete_all(&:blank?).join(";\n")
        end

        operation :db_name do |value|
          "NEW.#{value}"
        end

      end

      container :update_trigger do
        group do |validator|
          [validator.table_name, "trg_mgr_validates_#{validator.table_name}_upd"]
        end

        operation :create do |stmt, group_name|
          table_name, trigger_name = group_name

          "CREATE TRIGGER #{trigger_name} BEFORE UPDATE ON #{table_name} FOR EACH ROW
           BEGIN
            #{stmt}
           END;"
        end

        operation :drop do |stmt, group_name|
          table_name, trigger_name = group_name

          "DROP TRIGGER IF EXISTS #{trigger_name};"
        end

        operation :join do |stmt, value|
          [stmt, value].delete_all(&:blank?).join(";\n")
        end

        operation :db_name do |value|
          "NEW.#{value}"
        end
      end

      container :check do
      end
    end
  end
end
