require 'mv/core/validators/array_validator'
require_relative 'base'

module Mv
  module Core
    module Validation
      class BaseCollection < Base
        include ActiveModel::Validations

        attr_reader :in

        validates :in, presence: true, array: true

        def initialize(table_name, column_name, opts)
          opts = opts.is_a?(Hash) ? opts : { in: opts }

          super(table_name, column_name, opts)

          @in = opts.with_indifferent_access[:in]
        end

        def to_a
          prepared_in = self.in.is_a?(Range) ? range_to_a : self.in.try(:sort)
          super + [prepared_in]
        end

        protected

        def range_to_a
          min = self.in.min
          max = self.in.exclude_end? ? self.in.last - 0.000000001.second : self.in.last

          [min, max]
        end
      end
    end
  end
end
