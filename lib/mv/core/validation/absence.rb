require 'mv/core/validation/base'

module Mv
  module Core
    module Validation
      class Absence < Base
        include ActiveModel::Validations

        validate :nil_and_blank_can_not_be_both_denied

        def initialize(table_name, column_name, opts)
          super(table_name, column_name, opts)
        end

        private

        def nil_and_blank_can_not_be_both_denied
          if !(allow_blank || allow_nil)
            errors.add(:allow_blank, 'can not be denied when nil is denied')
          end
        end
      end
    end
  end
end