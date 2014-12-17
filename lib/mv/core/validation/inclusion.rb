module Mv
  module Core
    module Validation
      class Inclusion
        attr_reader :in, :message, :on, :create_trigger_name, :update_trigger_name, 
                    :allow_nil, :allow_blank, :as

        def initialize opts
          opts.with_indifferent_access.tap do |opts|
            @in = opts[:in]
            @message = opts[:message]
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