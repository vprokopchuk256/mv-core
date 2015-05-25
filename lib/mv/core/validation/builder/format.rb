module Mv
  module Core
    module Validation
      module Builder
        class Format < Mv::Core::Validation::Builder::Base
          delegate :with, to: :validation

          def conditions
            [{
              statement: apply_allow_nil_and_blank(apply_with(column_reference)),
              message: message
            }]
          end

          protected

          def db_value value
            return "'#{value.source}'" if value.is_a?(Regexp)
            return "'#{value.to_s}'" if value.is_a?(String)
            raise Mv::Core::Error.new(table_name: table_name,
                                      column_name: column_name,
                                      validation_type: :inclusion,
                                      options: { in: value },
                                      error: "#{value.class} is not supported as :with value")
          end

          def apply_with stmt
            "#{stmt} REGEXP #{db_value(with)}"
          end
        end
      end
    end
  end
end
