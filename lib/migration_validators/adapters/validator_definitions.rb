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
            self.wrap.or(column.db_name.null)
          end if opts[:allow_nil] || !opts.key?(:allow_nil)

          validator.post :allow_blank => true do
            self.wrap.or(column.db_name.coalesce.trim.length.equal_to(0))
          end if opts[:allow_blank] || !opts.key?(:allow_blank)

          validator.instance_eval(&block) if block
        end 

        def define_base_validators
          validator :inclusion  do
            property :in do |value|
              if value.kind_of?(Array)
                column.db_name.not_null.and(column.db_name.in(value)) 
              elsif value.kind_of?(Range)
                column.db_name.not_null.and(db_name.between(value))
              else
                column.db_name.not_null.and(column.db_name.equal_to(compile(value).db_value))
              end
            end
          end

          validator :exclusion  do
            property :in do |value|
              if value.kind_of?(Array)
                column.db_name.not_in(value)
              elsif value.kind_of?(Range)
                column.db_name.between(value).wrap.not 
              else
                column.db_name.equal_to(compile(value).db_value).not
              end
            end
          end

          validator :format  do
            property :with do |value| 
              column.db_name.not_null.and(column.db_name.regexp(compile(value).db_value))
            end
          end

          validator :length  do
            property :is, :message => :wrong_length do |value| 
              column.db_name.coalesce.length.equal_to(compile(value).db_value) 
            end
            property :maximum, :message => :too_long do |value| 
              column.db_name.coalesce.length.less_or_equal_to(compile(value).db_value) 
            end
            property :minimum, :message => :too_short do |value| 
              column.db_name.coalesce.length.greater_or_equal_to(compile(value).db_value) 
            end

            property :in do |value|
              case value.class.name 
                when "Array" then column.db_name.coalesce.length.in(value)
                when "Range" then column.db_name.coalesce.length.between(value)
                else column.db_name.coalesce.length.equal_to(compile(value).db_value)
              end
            end

            property :within do |value|
              case value.class.name 
                when "Array" then column.db_name.coalesce.length.in(value)
                when "Range" then column.db_name.coalesce.length.between(value)
                else column.db_name.coalesce.length.equal_to(compile(value).db_value)
              end
            end
          end

          validator :size  do
            property :is, :message => :wrong_length do |value| 
              column.db_name.coalesce.length.equal_to(compile(value).db_value) 
            end
            property :maximum, :message => :too_long do |value| 
              column.db_name.coalesce.length.less_or_equal_to(compile(value).db_value) 
            end
            property :minimum, :message => :too_short do |value| 
              column.db_name.coalesce.length.greater_or_equal_to(compile(value).db_value) 
            end

            property :in do |value|
              case value.class.name 
                when "Array" then column.db_name.coalesce.length.in(value)
                when "Range" then column.db_name.coalesce.length.between(value)
                else column.db_name.coalesce.length.equal_to(compile(value).db_value)
              end
            end

            property :within do |value|
              case value.class.name 
                when "Array" then column.db_name.coalesce.length.in(value)
                when "Range" then column.db_name.coalesce.length.between(value)
                else column.db_name.coalesce.length.equal_to(compile(value).db_value)
              end
            end
          end

          validator :presense  do
            property do |value| 
              column.db_name.not_null.and(column.db_name.trim.length.greater_than(0))
            end
          end

          validator :uniqueness do
            property do |value|
              "NOT EXISTS(SELECT #{column}  
                            FROM #{validator.table_name}
                           WHERE (#{column.db_name} = #{column}))"
            end
          end
        end
      end
    end
  end
end
