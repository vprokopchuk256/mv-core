module Mv
  module Core
    module Validation
      module Builder
        class Uniqueness
          attr_reader :validation

          delegate :allow_nil, 
                   :allow_blank, 
                   :column_name, 
                   :table_name, 
                   to: :validation

          def initialize(validation)
            @validation = validation
          end

          def to_sql
            res = "NOT EXISTS(SELECT #{column_name} 
                                FROM #{table_name} 
                               WHERE #{column_reference} = #{column_name})"

            if allow_nil
              res = apply_allow_nil(res)
            end

            if allow_blank
              res = apply_allow_nil(res) unless allow_nil
              res = apply_allow_blank(res)
            end

            res.squish
          end

          protected

          def column_reference 
            column_name
          end
          
          def apply_allow_nil stmt
            "#{stmt} OR #{column_reference} IS NULL"
          end

          def apply_allow_blank stmt
            "#{stmt} OR LENGTH(TRIM(#{column_reference})) = 0"
          end

        end
      end
    end
  end
end