require 'mv/core/validation/base'
require 'mv/core/validators/array_validator'

module Mv
  module Core
    module Validation
      class Inclusion < Base
        include ActiveModel::Validations

        attr_reader :in

        validates :in, presence: true, array: true

        def initialize(table_name, column_name, opts)
          opts = opts.is_a?(Hash) ? opts : { in: opts }
          
          super(table_name, column_name, opts)

          @in = opts.with_indifferent_access[:in]
        end
        
        def to_a
          prepared_in = self.in.is_a?(Range) ? [self.in.min, self.in.max] : self.in.try(:sort)
          super + [prepared_in]
        end

        protected

        def default_message
          'is not included in the list'
        end
      end
    end
  end
end