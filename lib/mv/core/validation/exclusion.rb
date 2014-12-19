require 'mv/core/validation/base'

module Mv
  module Core
    module Validation
      class Exclusion < Base
        include ActiveModel::Validations

        attr_reader :in

        validates :in, presence: true
        validate :in_type

        def initialize(table_name, column_name, opts)
          super(table_name, column_name, opts)

          @in = opts.with_indifferent_access[:in]
        end

        private

        def in_type
          errors.add(:in, 'must support conversion to Array (respond to :to_a method)') unless self.in.respond_to?(:to_a)
        end
      end
    end
  end
end