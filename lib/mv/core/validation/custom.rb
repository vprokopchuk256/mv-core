require 'mv/core/validation/base'

module Mv
  module Core
    module Validation
      class Custom < Base
        attr_reader :statement

        validates :statement, presence: true
        
        def initialize(table_name, column_name, opts)
          opts = opts.is_a?(Hash) ? opts : { statement: opts }
          
          super(table_name, column_name, opts)

          @statement = opts.with_indifferent_access[:statement]
        end

        def to_a
          super + [statement.to_s]
        end
      end
    end
  end
end