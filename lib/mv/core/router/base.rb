require 'mv/core/router/factory'
require 'mv/core/constraint/description'

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

        def route table_name, column_name, validation_type, opts
          factory.create_router(get_route(validation_type, opts)).route(
            table_name, column_name, validation_type, opts
          )
        end

        def set_route validation_type, constraint_type
          routing_map[validation_type] = constraint_type
        end

        private

        def get_route validation_type, opts
          opts[:as] || routing_map.fetch(validation_type, :trigger)
        end

        class << self
          delegate :route, to: :instance
        end
      end
    end
  end
end