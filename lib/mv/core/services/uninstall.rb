require 'mv/core/services/delete_constraints'

module Mv
  module Core
    module Services
      class Uninstall
        def execute
          if db.table_exists?(:migration_validators)
            ::ActiveRecord::Migration.say_with_time('drop migration_validators table') do
              Mv::Core::Services::DeleteConstraints.new.execute
              db.drop_table(:migration_validators)         
            end
          end
        end

        private

        def db
          ::ActiveRecord::Base.connection
        end
      end
    end
  end
end