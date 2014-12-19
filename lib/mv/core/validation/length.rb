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

        validates :on, inclusion: { in: :available_on }
        validates :allow_nil, :allow_blank, inclusion: { in: [true, false] }
        validates :as, inclusion: { in: :available_as }

        validates :in, :within, presence: true, allow_nil: true, integers_array: true
        validates :is, :minimum, :maximum, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

        def initialize(table_name, column_name, opts)
          @table_name = table_name
          @column_name = column_name

          opts.with_indifferent_access.tap do |opts|
            @in = opts[:in]
            @within = opts[:within]
            @is = opts[:is]
            @maximum = opts[:maximum]
            @minimum = opts[:minimum]
            @message = opts[:message] || default_message
            @too_long = opts[:too_long]
            @too_short = opts[:too_short]
            @on = opts[:on] || default_on
            @create_trigger_name = opts[:create_trigger_name] || default_create_trigger_name
            @update_trigger_name = opts[:update_trigger_name] || default_update_trigger_name
            @allow_nil = opts[:allow_nil] || default_allow_nil
            @allow_blank = opts[:allow_blank] || default_allow_blank
            @as = opts[:as] || default_as
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
          :save
        end

        def default_as
          :trigger
        end

        def default_create_trigger_name
          "trg_mv_#{table_name}_ins"
        end

        def default_update_trigger_name
          "trg_mv_#{table_name}_upd"
        end

        def default_allow_nil
          false
        end

        def default_allow_blank
          false
        end
      end
    end
  end
end