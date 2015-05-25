module Mv
  module Core
    module Validation
      class Format < Base
        attr_reader :with

        validates :with, presence: true

        def initialize(table_name, column_name, opts)
          opts = { with: opts } unless opts.is_a?(Hash)

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
