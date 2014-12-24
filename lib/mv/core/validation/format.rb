require 'mv/core/validation/base'

module Mv
  module Core
    module Validation
      class Format < Base
        include ActiveModel::Validations

        attr_reader :with

        validates :with, presence: true

        def initialize(table_name, column_name, opts)
          super(table_name, column_name, opts)

          @with = opts.with_indifferent_access[:with]
        end

        def to_a
          super + [with.to_s]
        end
      end
    end
  end
end