require 'mv/core/constraint/description'

module Mv
  module Core
    class Router
      include Singleton

      def route validation
        self.send("route_#{validation.as}", validation)
      end

      private

      def route_trigger validation
        [validation.create? && Mv::Core::Constraint::Description.new(validation.create_trigger_name,
                                                                     :trigger, 
                                                                     { event: :create }),
         validation.update? && Mv::Core::Constraint::Description.new(validation.update_trigger_name, 
                                                                     :trigger, 
                                                                     { event: :update })].select(&:present?)
      end

      def route_check validation
        [Mv::Core::Constraint::Description.new(validation.check_name, :check)]
      end

      def route_index validation
        [Mv::Core::Constraint::Description.new(validation.index_name, :index)]
      end

      class << self
        delegate :route, to: :instance
      end
    end
  end
end