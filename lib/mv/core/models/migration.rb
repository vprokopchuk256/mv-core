require 'mv/core/models/migration_validator'

module Mv
	module Core
		module Models
			class Migration
				attr_reader :version
				
				def initialize(version)
					@version = version
				end

				def add_validator opts
					MigrationValidator.create(opts.merge(version: version))
				end

				def validators
					MigrationValidator.joins("
						LEFT OUTER JOIN (#{MigrationValidator.where('version <= :version', version: version).to_sql}) mv
						             ON migration_validators.version < mv.version
						            AND migration_validators.table_name = mv.table_name
						            AND migration_validators.column_name = mv.column_name
						            AND migration_validators.validator_name = mv.validator_name
					").where('mv.id IS NULL
						    AND migration_validators.version <= :version', version: version)

				end


				cattr_reader :current

				def self.set_current(version)
					@@current = new(version)
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
			end
		end
	end
end