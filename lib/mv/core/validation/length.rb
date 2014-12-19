require 'mv/core/validation/validators/integers_array_validator'

module Mv
  module Core
    module Validation
      class Length
        include ActiveModel::Validations

        attr_reader :table_name, :column_name, 
                    :in, :within, :is, :maximum, :minimum, :message, 
                    :too_long, :too_short, :on, :create_trigger_name, 
                    :update_trigger_name, :allow_nil, :allow_blank, :as

        validates :on, inclusion: { in: :available_on }, allow_nil: true
        validates :allow_nil, :allow_blank, inclusion: { in: [true, false] }
        validates :as, inclusion: { in: :available_as }

        validates :in, :within, presence: true, allow_nil: true, integers_array: true
        validates :is, :minimum, :maximum, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

        validate :on_allowance,
                 :create_trigger_name_allowance, 
                 :update_trigger_name_allowance, 
                 :in_within_is_maximum_minimum_allowance

        def initialize(table_name, column_name, opts)
          @table_name = table_name
          @column_name = column_name

          opts.with_indifferent_access.tap do |opts|
            @as = opts[:as] || default_as
            @on = opts[:on] || default_on
            @in = opts[:in]
            @within = opts[:within]
            @is = opts[:is]
            @maximum = opts[:maximum]
            @minimum = opts[:minimum]
            @message = opts[:message] || default_message
            @too_long = opts[:too_long]
            @too_short = opts[:too_short]
            @create_trigger_name = opts[:create_trigger_name] || default_create_trigger_name
            @update_trigger_name = opts[:update_trigger_name] || default_update_trigger_name
            @allow_nil = opts[:allow_nil] || default_allow_nil
            @allow_blank = opts[:allow_blank] || default_allow_blank
          end
        end

        protected 

        def available_as
          [:trigger, :check]
        end

        def available_on 
          [:save, :update, :create]
        end

        def default_message
          "Length violated on the table #{table_name} column #{column_name}"
        end

        def default_on
          :save if trigger?
        end

        def default_as
          :trigger
        end

        def default_create_trigger_name
          "trg_mv_#{table_name}_ins" if create? && trigger?
        end

        def default_update_trigger_name
          "trg_mv_#{table_name}_upd" if update? && trigger?
        end

        def default_allow_nil
          false
        end

        def default_allow_blank
          false
        end

        private

        def trigger?
          as.to_sym == :trigger
        end

        def update?
          [:save, :update].include?(on.try(:to_sym))
        end

        def create?
          [:save, :create].include?(on.try(:to_sym))
        end

        def on_allowance  
          errors.add(:on, 'allowed when :as == :trigger') if on && !trigger? 
        end

        def create_trigger_name_allowance
          if create_trigger_name.present? &&
             (![:save, :create].include?(on.to_sym) || as.to_sym != :trigger)
            errors.add(:create_trigger_name, 'allowed when :on in [:save, :create] and :as == :trigger')
          end
        end

        def update_trigger_name_allowance
          if update_trigger_name.present? &&
             (![:save, :update].include?(on.to_sym) || as.to_sym != :trigger)
            errors.add(:update_trigger_name, 'allowed when :on in [:save, :create] and :as == :trigger')
          end
        end

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