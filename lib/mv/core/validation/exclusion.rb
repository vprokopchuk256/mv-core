require 'mv/core/validation/base'
require 'mv/core/validation/validators/array_validator'

module Mv
  module Core
    module Validation
      class Exclusion < Base
        include ActiveModel::Validations

        attr_reader :in

        validates :in, presence: true, array: true

        def initialize(table_name, column_name, opts)
          super(table_name, column_name, opts)

          @in = opts.with_indifferent_access[:in]
        end
      end
    end
  end
end