require 'mv/core/constraint/description'

module Mv
  module Core
    module Router
      class Trigger
        def route validation
          return [].tap do |res|
              res << Mv::Core::Constraint::Description.new(validation.create_trigger_name,
                                                           :trigger, 
                                                           { event: :create }) if validation.create?

              res << Mv::Core::Constraint::Description.new(validation.update_trigger_name, 
                                                           :trigger, 
                                                           { event: :update }) if validation.update?
          end
        end
      end
    end
  end
end