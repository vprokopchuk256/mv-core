module Mv
  module Core
    module Db
      class MigrationValidator < ::ActiveRecord::Base
        validates :table_name, presence: true
        validates :column_name, presence: true
        validates :validator_name, presence: true

        serialize :options, Hash
      end
    end
  end
end