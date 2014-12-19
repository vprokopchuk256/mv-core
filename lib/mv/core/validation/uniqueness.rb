module Mv
  module Core
    module Validation
      class Uniqueness
        include ActiveModel::Validations

        attr_reader :table_name, :column_name, 
                    :message, :index_name, :on, :create_trigger_name, 
                    :update_trigger_name, :allow_nil, :allow_blank, :as

        validates :on, inclusion: { in: :available_on }
        validates :allow_nil, :allow_blank, inclusion: { in: [true, false] }
        validates :as, inclusion: { in: :available_as }

        def initialize(table_name, column_name, opts)
          @table_name = table_name
          @column_name = column_name
          
          opts.with_indifferent_access.tap do |opts|
            @message = opts[:message] || default_message
            @index_name = opts[:index_name] || default_index_name
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
          [:trigger, :check, :index]
        end

        def available_on 
          [:save, :update, :create]
        end

        def default_message
          "Uniqueness violated on the table #{table_name} column #{column_name}"
        end

        def default_on
          :save
        end

        def default_as
          :index
        end

        def default_create_trigger_name
          "trg_mv_#{table_name}_ins"
        end

        def default_update_trigger_name
          "trg_mv_#{table_name}_upd" 
        end

        def default_index_name
          "idx_mv_#{table_name}_#{column_name}_uniq"
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