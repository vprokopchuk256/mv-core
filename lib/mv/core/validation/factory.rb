require 'mv/core/validation/uniqueness'
require 'mv/core/validation/exclusion'
require 'mv/core/validation/format'
require 'mv/core/validation/inclusion'
require 'mv/core/validation/length'
require 'mv/core/validation/presence'

module Mv
  module Core
    module Validation
      class Factory
        def create_validation table_name, column_name, type, opts
          "Mv::Core::Validation::#{type.to_s.camelize}".constantize.new(table_name, 
                                                                        column_name, 
                                                                        opts)
        end 
      end
    end
  end
end