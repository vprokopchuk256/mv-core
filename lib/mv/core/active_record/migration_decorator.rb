require 'mv/core/migration/base'

module Mv
  module Core
    module ActiveRecord
      module MigrationDecorator
        def exec_migration(conn, direction)
          Mv::Core::Migration::Base.set_current(version)
          super
          Mv::Core::Migration::Base.execute()
        end
      end
    end
  end
end