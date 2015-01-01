module Mv
  module Core
    module Validation
      module Builder
        class Exclusion
          attr_reader :validation

          delegate :column_name,
                   :in,
                   :allow_nil,
                   :allow_blank,
                   to: :validation

          def initialize(validation)
            @validation = validation
          end

          def to_sql
            res = apply_in(column_reference)

            if allow_nil
              res = apply_allow_nil(res)
            end

            if allow_blank
              res = apply_allow_nil(res) unless allow_nil
              res = apply_allow_blank(res)
            end

            res
          end

          protected

          def db_value value
            return value if value.is_a?(Integer)
            "'#{value.to_s}'"
          end

          def column_reference 
            column_name
          end

          def apply_in stmt
            if self.in.is_a?(Range)
              "#{stmt} < #{self.in.min} OR #{stmt} > #{self.in.max}"
            else
              prepared_in = self.in.to_a.collect{ |v| db_value(v) }

              "#{stmt} NOT IN (#{prepared_in.join(', ')})" 
            end
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