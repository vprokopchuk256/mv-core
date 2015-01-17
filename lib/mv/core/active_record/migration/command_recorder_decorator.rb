module Mv
  module Core
    module ActiveRecord
      module Migration
        module CommandRecorderDecorator
          def validates(*args, &block)
            record(:validates, args, &block)
          end
        end
      end
    end
  end
end