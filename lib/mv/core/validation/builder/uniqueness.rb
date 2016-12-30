require_relative 'base'

module Mv
  module Core
    module Validation
      module Builder
        class Uniqueness < Base
          def conditions
            res = "NOT EXISTS(SELECT #{column_name}
                                FROM #{table_name}
                               WHERE #{column_reference} = #{column_name})"

            [{statement: apply_allow_nil_and_blank(res).squish, message: message}]
          end
        end
      end
    end
  end
end
