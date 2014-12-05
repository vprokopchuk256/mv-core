require 'mv/core/migration/operations/base'

require 'mv/core/db/migration_validator'
require 'mv/core/db/helpers/delete_migration_validator'
require 'mv/core/db/helpers/create_migration_validator'
require 'mv/core/db/helpers/update_migration_validator'

module Mv
  module Core
    module Migration
      module Operations
        class ChangeColumn < Base
          include Mv::Core::Db::Helpers::DeleteMigrationValidator
          include Mv::Core::Db::Helpers::CreateMigrationValidator
          include Mv::Core::Db::Helpers::UpdateMigrationValidator

          attr_reader :column_name, :opts

          def initialize(table_name, column_name, opts)
            super table_name
            @column_name = column_name
            @opts = opts
          end

          def execute
            opts.each do |validator_name, validator_opts|
              if validator_opts == false
                delete_migration_validator(table_name, column_name, validator_name)
                next
              end

              if Mv::Core::Db::MigrationValidator.where(table_name: table_name, 
                                                        column_name: column_name, 
                                                        validator_name: validator_name).exists?
                update_migration_validator(table_name, column_name, validator_name, validator_opts)
              else
                create_migration_validator(table_name, column_name, validator_name, validator_opts)
              end
            end
          end
        end
      end
    end
  end
end