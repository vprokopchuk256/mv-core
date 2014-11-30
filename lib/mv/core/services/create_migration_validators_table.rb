module Mv
	module Core
		module Services
			class CreateMigrationValidatorsTable
				delegate :create_table, :table_exists?, :add_index, to: :db

				def execute
					create_table(:migration_validators) do |table|
						table.string :version, null: false
						table.string :table_name, null: false
						table.string :column_name, null: false
						table.string :validator_name, null: false
						table.string :options
					end unless table_exists?(:migration_validators)

				  add_index(:migration_validators, 
								    [:version, :table_name, :column_name, :validator_name], 
								    name: 'unique_idx_on_migration_validators')
				end

				private

				def db
					ActiveRecord::Base.connection
				end
			end
		end
	end
end