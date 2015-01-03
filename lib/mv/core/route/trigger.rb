module Mv
  module Core
    module Route
      class Trigger
        attr_reader :validation

        def initialize(validation)
          @validation = validation
        end

        def route
          [validation.create? && Mv::Core::Constraint::Description.new(validation.create_trigger_name,
                                                                       :trigger, 
                                                                       { event: :create }),
           validation.update? && Mv::Core::Constraint::Description.new(validation.update_trigger_name, 
                                                                       :trigger, 
                                                                       { event: :update })].select(&:present?)
        end
      end
    end
  end
end