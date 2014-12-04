require 'mv/core/migration/operations/add_column'
require 'mv/core/migration/operations/change_column'
require 'mv/core/migration/operations/drop_table'
require 'mv/core/migration/operations/remove_column'
require 'mv/core/migration/operations/rename_column'
require 'mv/core/migration/operations/rename_table'

module Mv
	module Core
		module Migration
			module Operations
				class Factory
					attr_reader :version

					def initialize version
						@version = version
					end

					def create_operation operation_name, *args
						"Mv::Core::Migration::Operations::#{operation_name.to_s.camelize}".constantize.new(version, *args)
					end
				end
			end
		end
	end
end