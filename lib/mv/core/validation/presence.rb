require 'mv/core/validation/base'

module Mv
  module Core
    module Validation
      class Presence < Base
        include ActiveModel::Validations

        validate :nil_and_blank_can_not_be_both_allowed

        def initialize(table_name, column_name, opts)
          super(table_name, column_name, opts == true ? {} : opts)
        end

        protected

        def default_message
          "can't be blank"
        end

        private

        def nil_and_blank_can_not_be_both_allowed
          if allow_blank && allow_nil
            errors.add(:allow_blank, 'can not be allowed when nil is allowed')
          end
        end
      end
    end
  end
end