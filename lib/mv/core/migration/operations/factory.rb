require_relative 'add_column'
require_relative 'change_column'
require_relative 'drop_table'
require_relative 'remove_column'
require_relative 'rename_column'
require_relative 'rename_table'

module Mv
  module Core
    module Migration
      module Operations
        class Factory
          def create_operation operation_name, *args
            "Mv::Core::Migration::Operations::#{operation_name.to_s.camelize}".constantize.new(*args)
          end
        end
      end
    end
  end
end
