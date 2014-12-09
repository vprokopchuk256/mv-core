module Mv
  module Core
    module Router
      class Trigger
        def route validator
          return {}.tap do |res|
            res.merge!(
              create_trigger_name(validator) => { type: :trigger, event: :create }
            ) if define_create_trigger?(validator)

            res.merge!(
              update_trigger_name(validator) => { type: :trigger, event: :update }
            ) if define_update_trigger?(validator)
          end
        end

        private

        def opts validator
          validator.options.with_indifferent_access
        end

        def event validator
          opts(validator).fetch(:on, :save).to_s 
        end

        def define_create_trigger? validator
          ['save', 'create'].include?(event(validator))
        end

        def define_update_trigger? validator
          ['save', 'update'].include?(event(validator))
        end

        def create_trigger_name validator
          opts(validator).fetch(:create_trigger_name, :"trg_mv_#{validator.table_name}_ins")
        end

        def update_trigger_name validator
          opts(validator).fetch(:update_trigger_name, :"trg_mv_#{validator.table_name}_upd")
        end
      end
    end
  end
end