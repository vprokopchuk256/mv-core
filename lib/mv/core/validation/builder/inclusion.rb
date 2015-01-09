require 'mv/core/validation/builder/base'

module Mv
  module Core
    module Validation
      module Builder
        class Inclusion < Base
          delegate :in, to: :validation

          def conditions
            [{
              statement: apply_allow_nil_and_blank(apply_in(column_reference)), 
              message: message
            }]
          end

          protected

          def db_value value
            return value if value.is_a?(Integer) or value.is_a?(Float)
            return "'#{value.to_s}'" if value.is_a?(String)
            raise Mv::Core::Error.new(table_name: table_name, 
                                      column_name: column_name, 
                                      validation_type: :inclusion, 
                                      options: { in: value }, 
                                      error: "#{value.class} is not supported as :in value")
          end

          def apply_in stmt
            if self.in.is_a?(Range)
              "#{stmt} BETWEEN #{db_value(self.in.min)} AND #{db_value(self.in.max)}"
            else
              prepared_in = self.in.to_a.collect{ |v| db_value(v) }

              "#{stmt} IN (#{prepared_in.join(', ')})" 
            end
          end
        end
      end
    end 
  end
end