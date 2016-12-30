require_relative 'base_collection'

module Mv
  module Core
    module Validation
      class Inclusion < BaseCollection
        protected

        def default_message
          'is not included in the list'
        end
      end
    end
  end
end
