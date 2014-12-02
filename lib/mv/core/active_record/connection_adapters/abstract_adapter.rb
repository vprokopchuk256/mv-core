require 'mv/core/models/migration'

module Mv
	module Core
		module ActiveRecord
			module ConnectionAdapters
				module AbstractAdapter
					def add_column table_name, column_name, type, opts
						Mv::Core::Models::Migration.add_column(table_name, column_name, opts.delete(:validates))	
						
						super 
					end

					def remove_column table_name, *column_names
						column_names.flatten.each do |column_name|
							Mv::Core::Models::Migration.remove_column table_name, column_name
						end

						super 
					end

					def rename_column table_name, old_column_name, new_column_name
						Mv::Core::Models::Migration.rename_column table_name, old_column_name, new_column_name

						super
					end

					def change_column table_name, column_name, type, opts
						Mv::Core::Models::Migration.change_column(table_name, column_name, opts.delete(:validates))

						super
					end

					def rename_table old_table_name, new_table_name
						Mv::Core::Models::Migration.rename_table(old_table_name, new_table_name)

						super
					end

					def drop_table table_name
						Mv::Core::Models::Migration.drop_table(table_name)

						super
					end
				end
			end
		end
	end
end