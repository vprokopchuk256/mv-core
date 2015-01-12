require 'mv/core/db/migration_validator'

module Mv
  module Core
    module Db
      module Helpers
        module TableValidators
          attr_accessor :table_name
          
          def table_validators
            Mv::Core::Db::MigrationValidator.where(table_name: table_name)
          end

          def delete_table_validators
            delete_validators(table_validators)
          end

          def update_table_validators new_table_name
            table_validators.update_all(table_name: new_table_name)
          end

          private

          def say(message) 
            ::ActiveRecord::Migration.say(message)
          end

          def delete_validators validators
            validators.each do |validator|
              say("remove validation -- #{validator.to_say}")
              validator.destroy
            end
            validators.length
          end
        end
      end
    end
  end
end