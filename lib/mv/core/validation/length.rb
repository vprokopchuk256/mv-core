module Mv
  module Core
    module Validation
      class Length
        attr_reader :table_name, :column_name, 
                    :in, :within, :is, :maximum, :minimum, :message, 
                    :too_long, :too_short, :on, :create_trigger_name, 
                    :update_trigger_name, :allow_nil, :allow_blank, :as

        def initialize(table_name, column_name, opts)
          @table_name = table_name
          @column_name = column_name

          opts.with_indifferent_access.tap do |opts|
            @in = opts[:in]
            @within = opts[:within]
            @is = opts[:is]
            @maximum = opts[:maximum]
            @minimum = opts[:minimum]
            @message = opts[:message]
            @too_long = opts[:too_long]
            @too_short = opts[:too_short]
            @on = opts[:on]
            @create_trigger_name = opts[:create_trigger_name]
            @update_trigger_name = opts[:update_trigger_name]
            @allow_nil = opts[:allow_nil]
            @allow_blank = opts[:allow_blank]
            @as = opts[:as]
          end
        end
      end
    end
  end
end