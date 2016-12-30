require_relative 'base_collection'

module Mv
  module Core
    module Validation
      class Exclusion < BaseCollection
        protected

        def default_message
          'is reserved'
        end
      end
    end
  end
end
