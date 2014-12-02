
require 'mv/core/models/migration'

module Mv
	module Core
		module ActiveRecord
			module ConnectionAdapters
				module TableDefinition
	        def column column_name, type, opts = {}
						Mv::Core::Models::Migration.add_column(name, column_name, opts.delete(:validates))	

	        	super
					end
				end
			end
		end
	end
end