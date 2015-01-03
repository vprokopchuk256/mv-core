require 'mv/core/constraint/description'

require 'mv/core/route/trigger'
require 'mv/core/route/index'

module Mv
  module Core
    class Router
      include Singleton

      def route validation
        routing_table[validation.as.to_sym].new(validation).route
      end

      def define_route as, klass
        routing_table[as.to_sym] = klass
      end

      private

      def routing_table
        @routing_table ||= {
          trigger: Mv::Core::Route::Trigger, 
          index: Mv::Core::Route::Index
        }
      end

      class << self
        delegate :route, :define_route, to: :instance
      end
    end
  end
end