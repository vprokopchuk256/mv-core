module Mv
  module Core
    module Validation
      module Builder
        class Base
          attr_reader :validation 

          delegate :table_name, 
                   :column_name, 
                   :allow_nil, 
                   :allow_blank, to: :validation

          def initialize(validation)
            @validation = validation
          end
          
          protected

          def message
            validation.full_message
          end
          
          def column_reference 
            column_name
          end

          def apply_allow_nil_and_blank stmt
            res = stmt

            if allow_nil || allow_blank
              if allow_nil
                res = apply_allow_nil(res)
              end

              if allow_blank
                res = apply_allow_nil(res) unless allow_nil
                res = apply_allow_blank(res)
              end
            else
              res = apply_neither_nil_or_blank_allowed(stmt)
            end

            res
          end

          def apply_allow_nil stmt
            "#{stmt} OR #{column_reference} IS NULL"
          end

          def apply_allow_blank stmt
            "#{stmt} OR LENGTH(TRIM(#{column_reference})) = 0"
          end

          def apply_neither_nil_or_blank_allowed stmt
            "#{column_reference} IS NOT NULL AND #{stmt}"
          end
        end
      end
    end
  end
end