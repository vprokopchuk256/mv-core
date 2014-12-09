require 'mv/core/router/trigger'
require 'mv/core/router/check'
require 'mv/core/router/index'

module Mv
  module Core
    module Router
      class Factory
        def create_router(container_type)
          klass = "Mv::Core::Router::#{container_type.to_s.camelize}".constantize
          klass.new
        end
      end
    end
  end
end