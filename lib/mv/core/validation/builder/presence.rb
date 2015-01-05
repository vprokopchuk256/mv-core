require 'mv/core/validation/builder/base'

module Mv
  module Core
    module Validation
      module Builder
        class Presence < Base

          def to_sql
            null_stmt = "#{column_reference} #{allow_nil ? 'IS' : 'IS NOT'} NULL"
            blank_stmt = "LENGTH(TRIM(#{column_reference})) #{allow_blank ? '=' : '>'} 0"
            join_stmt = allow_nil || allow_blank ? 'OR' : 'AND'

            [null_stmt, join_stmt, blank_stmt].join(' ')
          end
        end
      end
    end
  end
end