module Mv
  module Core
    module Validation
      module Builder
        class Presence
          attr_reader :validation

          delegate :column_name,
                   :allow_nil,
                   :allow_blank,
                   to: :validation

          def initialize(validation)
            @validation = validation
          end

          def to_sql
            null_stmt = "#{column_reference} #{allow_nil ? 'IS' : 'IS NOT'} NULL"
            blank_stmt = "LENGTH(TRIM(#{column_reference})) #{allow_blank ? '=' : '>'} 0"
            join_stmt = allow_nil || allow_blank ? 'OR' : 'AND'

            [null_stmt, join_stmt, blank_stmt].join(' ')
          end

          protected

          def column_reference 
            column_name
          end
        end
      end
    end
  end
end