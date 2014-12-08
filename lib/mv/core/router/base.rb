require 'mv/core/router/factory'

module Mv
  module Core
    module Router
      class Base
        include Singleton

        attr_reader :factory

        def initialize 
          @factory = Mv::Core::Router::Factory.new()
        end

        def route validator
          factory.create_router(validator).route(validator)
        end

        class << self
          delegate :route, to: :instance
        end
      end
    end
  end
end