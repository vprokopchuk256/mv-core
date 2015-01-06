module Mv
  module Core
    module Validation
      module Builder
        class Base
          attr_reader :validation 

          delegate :table_name, 
                   :column_name, 
                   :message, 
                   :allow_nil, 
                   :allow_blank, to: :validation

          def initialize(validation)
            @validation = validation
          end
          
          protected
          
          def column_reference 
            column_name
          end

          def apply_allow_nil_and_blank stmt
            res = stmt

            if allow_nil
              res = apply_allow_nil(res)
            end

            if allow_blank
              res = apply_allow_nil(res) unless allow_nil
              res = apply_allow_blank(res)
            end

            res
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