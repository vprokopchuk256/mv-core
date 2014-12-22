module Mv
  module Core
    module Router
      class Trigger
        def route table_name, column_name, validation_type, options
          return [].tap do |res|
            if define_create_trigger?(options)
              res << [create_trigger_name(table_name, options), :trigger, { event: :create }]
            end

            if define_update_trigger?(options)
              res << [update_trigger_name(table_name, options), :trigger, { event: :update }]
            end
          end
        end

        private

        def opts validator
          validator.options.with_indifferent_access
        end

        def event options
          options.with_indifferent_access.fetch(:on, :save).to_s 
        end

        def define_create_trigger? options
          ['save', 'create'].include?(event(options))
        end

        def define_update_trigger? options
          ['save', 'update'].include?(event(options))
        end

        def create_trigger_name table_name, options
          options.with_indifferent_access.fetch(:create_trigger_name, :"trg_mv_#{table_name}_ins")
        end

        def update_trigger_name table_name, options
          options.with_indifferent_access.fetch(:update_trigger_name, :"trg_mv_#{table_name}_upd")
        end
      end
    end
  end
end