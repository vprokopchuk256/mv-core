require 'mv/core/validation/base'

module Mv
  module Core
    module Validation
      class Presence < Base
        include ActiveModel::Validations

        def initialize(table_name, column_name, opts)
          super(table_name, column_name, opts)
        end
      end
    end
  end
end