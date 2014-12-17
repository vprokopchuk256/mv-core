module Mv
  module Core
    module Validation
      class Uniqueness
        attr_reader :message, :index_name, :on, :create_trigger_name, 
                    :update_trigger_name, :allow_nil, :allow_blank, :as

        def initialize(opts)
          opts.with_indifferent_access.tap{ |opts|
            @message = opts[:message]
            @index_name = opts[:index_name]
            @on = opts[:on]
            @create_trigger_name = opts[:create_trigger_name]
            @update_trigger_name = opts[:update_trigger_name]
            @allow_nil = opts[:allow_nil]
            @allow_blank = opts[:allow_blank]
            @as = opts[:as]
          }
        end
      end
    end
  end
end