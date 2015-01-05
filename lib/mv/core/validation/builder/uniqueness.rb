require 'mv/core/validation/builder/base'

module Mv
  module Core
    module Validation
      module Builder
        class Uniqueness < Base
          def to_sql
            res = "NOT EXISTS(SELECT #{column_name} 
                                FROM #{table_name} 
                               WHERE #{column_reference} = #{column_name})"

            apply_allow_nil_and_blank(res).squish
          end
        end
      end
    end
  end
end