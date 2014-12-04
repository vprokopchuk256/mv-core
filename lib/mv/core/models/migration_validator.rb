module Mv
	module Core
		module Models
			class MigrationValidator < ActiveRecord::Base
				validates :version, presence: true
				validates :table_name, presence: true
				validates :column_name, presence: true
				validates :validator_name, presence: true

				serialize :options, Hash

				scope :for_version, -> (version) { where(version: version) }

				scope :recent, -> {
					where("version = (SELECT MAX(version) FROM migration_validators)")
				}

				def clone_with_version(version)
					return clone.tap { |v| v.version = version }
				end
			end
		end
	end
end