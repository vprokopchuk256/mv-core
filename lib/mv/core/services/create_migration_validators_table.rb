module Mv
	module Core
		module Services
			class CreateMigrationValidatorsTable
				delegate :create_table, :table_exists?, to: :db

				def execute
					create_table(:migration_validators) do |table|
						table.string :table_name, null: false
						table.string :column_name, null: false
					end unless table_exists?(:migration_validators)
				end

				private

				def db
					ActiveRecord::Base.connection
				end
			end
		end
	end
end