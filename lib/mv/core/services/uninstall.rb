require 'mv/core/services/delete_constraints'

module Mv
  module Core
    module Services
      class Uninstall
        def execute
          if db.data_source_exists?(:migration_validators)
            Mv::Core::Services::DeleteConstraints.new.execute

            ::ActiveRecord::Migration.say_with_time('drop migration_validators table') do
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
