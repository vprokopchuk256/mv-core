require 'mv/core/validation/base'
require 'mv/core/validation/validators/integers_array_validator'

module Mv
  module Core
    module Validation
      class Length < Base
        include ActiveModel::Validations

        attr_reader :in, :within, :is, :maximum, :minimum, 
                    :too_long, :too_short

        validates :in, :within, presence: true, allow_nil: true, integers_array: true
        validates :is, :minimum, :maximum, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

        validate :in_within_is_maximum_minimum_allowance

        def initialize(table_name, column_name, opts)
          super(table_name, column_name, opts)

          opts.with_indifferent_access.tap do |opts|
            @in = opts[:in]
            @within = opts[:within]
            @is = opts[:is]
            @maximum = opts[:maximum]
            @minimum = opts[:minimum]
            @too_long = opts[:too_long]
            @too_short = opts[:too_short]
          end
        end

        private

        def in_within_is_maximum_minimum_allowance
          not_null_attrs = [[is, :is], 
                            [within, :within], 
                            [self.in, :in], 
                            [maximum || minimum, :minimum_or_maximum]]
                          .select(&:first).collect(&:second)

          if not_null_attrs.length != 1
            not_null_attrs << :is if not_null_attrs.blank?

            not_null_attrs.each do |attr|
              errors.add(
                attr,
                'One and only one attribute from the list [:is, :within, :in, [:minimum, :maximum] can be defined'
              )
            end
          end
        end
      end
    end
  end
end