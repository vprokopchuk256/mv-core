require 'mv/core/router/trigger'
require 'mv/core/router/check'
require 'mv/core/router/index'

module Mv
  module Core
    module Router
      class Factory
        attr_reader :default_route

        def initialize default_route = :trigger
          @default_route = default_route 
        end

        def create_router(validator)
          klass = "Mv::Core::Router::#{validator.options.with_indifferent_access.fetch(:as, default_route).to_s.camelize}".constantize
          klass.new(validator.table_name, validator.column_name, validator.options)
        end

        protected
      end
    end
  end
end