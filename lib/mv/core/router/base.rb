require 'mv/core/router/factory'

module Mv
  module Core
    module Router
      class Base
        include Singleton

        attr_reader :factory, :routing_map

        def initialize 
          @factory = Mv::Core::Router::Factory.new()

          @routing_map = {
            uniqueness: :index, 
            length: :trigger, 
            inclusion: :trigger, 
            exclusion: :trigger, 
            presence: :trigger, 
            format: :trigger
          }.with_indifferent_access
        end

        def route validator
          factory.create_router(get_route(validator)).route(validator)
        end

        def set_route validator_name, container_type
          routing_map[validator_name] = container_type
        end

        private

        def get_route validator
          validator.options[:as] || routing_map.fetch(validator.validator_name, :trigger)
        end

        class << self
          delegate :route, to: :instance
        end
      end
    end
  end
end