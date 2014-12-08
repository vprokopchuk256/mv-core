module Mv
  module Core
    module Db
      class MigrationValidator < ::ActiveRecord::Base
        serialize :options, Hash
        serialize :containers, Hash

        validates :table_name, presence: true
        validates :column_name, presence: true
        validates :validator_name, presence: true
      end
    end
  end
end