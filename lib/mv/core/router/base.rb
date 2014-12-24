require 'mv/core/router/factory'
require 'mv/core/constraint/description'

module Mv
  module Core
    module Router
      class Base
        include Singleton

        attr_reader :factory

        def initialize 
          @factory = Mv::Core::Router::Factory.new()
        end

        def route validation
          factory.create_router(validation.as).route(validation)
        end

        private

        class << self
          delegate :route, to: :instance
        end
      end
    end
  end
end