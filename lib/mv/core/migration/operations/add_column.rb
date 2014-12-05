require 'mv/core/migration/operations/base'

require 'mv/core/db/helpers/create_migration_validator'

module Mv
  module Core
    module Migration
      module Operations
        class AddColumn < Base
          include Mv::Core::Db::Helpers::CreateMigrationValidator

          attr_reader :column_name, :opts

          def initialize(table_name, column_name, opts)
            super table_name
            @column_name = column_name
            @opts = opts
          end

          def execute
            opts.each do |validator_name, validator_opts|
              create_migration_validator(table_name, column_name, validator_name, validator_opts)
            end
          end
        end
      end
    end
  end
end