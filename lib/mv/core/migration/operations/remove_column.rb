require 'mv/core/migration/operations/base' 

module Mv
	module Core
		module Migration
			module Operations
				class RemoveColumn < Base
					attr_reader :column_name

					def initialize(version, table_name, column_name)
						super version, table_name

						@column_name = column_name
					end
				end
			end
		end
	end
end