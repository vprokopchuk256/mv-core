module Mv
  module Core
    module Validation
      module Builder
        class Length
          attr_reader :validation

          delegate :column_name,
                   :in, 
                   :within, 
                   :is, 
                   :maximum, 
                   :minimum,
                   :allow_nil,
                   :allow_blank,
                   to: :validation

          def initialize(validation)
            @validation = validation 
          end
          
          def to_sql
            res = apply_in(column_reference) if self.in
            res = apply_within(column_reference) if within
            res = apply_is(column_reference) if self.is
            res = apply_maximum(column_reference) if maximum && !minimum
            res = apply_minimum(column_reference) if minimum && !maximum
            res = apply_minimum_and_maximum(column_reference) if minimum && maximum

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

          def column_reference 
            column_name
          end

          def apply_in stmt
            if self.in.is_a?(Range)
              "LENGTH(#{stmt}) BETWEEN #{self.in.min} AND #{self.in.max}"
            else
              "LENGTH(#{stmt}) IN (#{self.in.join(', ')})"
            end
          end

          def apply_within stmt
            if within.is_a?(Range)
              "LENGTH(#{stmt}) BETWEEN #{within.min} AND #{within.max}"
            else
              "LENGTH(#{stmt}) IN (#{within.join(', ')})"
            end
          end

          def apply_is stmt
            "LENGTH(#{stmt}) = #{self.is}"
          end

          def apply_maximum stmt
            "LENGTH(#{stmt}) <= #{maximum}"
          end

          def apply_minimum stmt
            "LENGTH(#{stmt}) >= #{minimum}"
          end

          def apply_minimum_and_maximum stmt
            "LENGTH(#{stmt}) BETWEEN #{minimum} AND #{maximum}"
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