module Mv
  module Core
    module Db
      class MigrationValidator < ::ActiveRecord::Base
        serialize :options, Hash
        serialize :constraints, Hash

        validates :table_name, presence: true
        validates :column_name, presence: true
        validates :validation_type, presence: true
      end
    end
  end
end