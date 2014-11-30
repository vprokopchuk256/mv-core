module Mv
	module Core
		module Models
			class MigrationValidator < ActiveRecord::Base
				validates :version, presence: true
				validates :table_name, presence: true
				validates :column_name, presence: true
				validates :validator_name, presence: true

				serialize :options, Hash
			end
		end
	end
end