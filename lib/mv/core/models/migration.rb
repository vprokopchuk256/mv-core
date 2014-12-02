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
					puts "add_column called. table_name #{table_name}, column_name: #{column_name}, opts: #{opts}"
				end

				def remove_column table_name, column_name
					puts "remove_column called. table_name: #{table_name} column_name: #{column_name}"
				end

				def rename_column table_name, old_column_name, new_column_name
					puts "rename_column called. table_name: #{table_name} old_column_name: #{old_column_name} new_column_name: #{new_column_name}"
				end

				def change_column table_name, column_name, opts
					puts "change_column called table_name: #{table_name} column_name: #{column_name} opts: #{opts}"
				end

				def rename_table old_table_name, new_table_name
					puts "rename_table called old_table_name: #{old_table_name}, new_table_name: #{new_table_name}"
				end

				def drop_table table_name
					puts "drop_table called table_name: #{table_name}"
				end

				class << self
					delegate :add_column, :remove_column, :rename_column, :change_column, 
					         :rename_table, :drop_table, to: :current, allow_nil: true
				end
			end
		end
	end
end