require 'mv/core/validation/builder/base'

module Mv
  module Core
    module Validation
      module Builder
        class Length < Base
          delegate :in, 
                   :within, 
                   :is, 
                   :maximum, 
                   :minimum,
                   :too_short, 
                   :too_long,
                   to: :validation

          def conditions
            res = apply_in(column_reference) if self.in
            res = apply_within(column_reference) if within
            res = apply_is(column_reference) if self.is
            res = apply_maximum(column_reference) if maximum && !minimum
            res = apply_minimum(column_reference) if minimum && !maximum
            res = apply_minimum_and_maximum(column_reference) if minimum && maximum

            res.collect do |condition| 
              { statement: apply_allow_nil_and_blank(condition[:statement]), message: condition[:message] }
            end
          end

          protected

          def apply_in stmt
            [{ statement: self.in.is_a?(Range) ? "LENGTH(#{stmt}) BETWEEN #{self.in.min} AND #{self.in.max}" :
                                                 "LENGTH(#{stmt}) IN (#{self.in.join(', ')})",
              message: message }]
          end

          def apply_within stmt
            [{ statement: within.is_a?(Range) ? "LENGTH(#{stmt}) BETWEEN #{within.min} AND #{within.max}" :
                                                "LENGTH(#{stmt}) IN (#{within.join(', ')})",
              message: message }]
          end

          def apply_is stmt
            [{ statement: "LENGTH(#{stmt}) = #{self.is}", message: message }]
          end

          def apply_maximum stmt
            [{ statement: "LENGTH(#{stmt}) <= #{maximum}", message: too_long || message }]
          end

          def apply_minimum stmt
            [{ statement: "LENGTH(#{stmt}) >= #{minimum}", message: too_short || message }]
          end

          def apply_minimum_and_maximum stmt
            if too_long == too_short
              [{ statement: "LENGTH(#{stmt}) BETWEEN #{minimum} AND #{maximum}", 
                message: message }]
            else
              [apply_minimum(stmt), apply_maximum(stmt)].flatten
            end
          end
        end
      end
    end
  end
end