require 'mv/core/models/migration_validator'

module Mv
	module Core
		module Models
			class Migration
				attr_reader :version
				
				def initialize(version)
					@version = version
				end

				def add_column table_name, column_name, opts
				end

				def remove_column table_name, column_name
				end

				def rename_column table_name, old_column_name, new_column_name
				end

				def change_column table_name, column_name, opts
				end

				def rename_table old_table_name, new_table_name
				end

				def drop_table table_name
				end

				class << self
					attr_reader :current

					def set_current(version)
						@current = new(version)
					end

					delegate :add_column, :remove_column, :rename_column, :change_column, 
					         :rename_table, :drop_table, to: :current, allow_nil: true
				end
			end
		end
	end
end