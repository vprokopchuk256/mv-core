require 'mv/core/migration/base'

module Mv
  module Core
    module ActiveRecord
      module MigrationDecorator
        def exec_migration(conn, direction)
          super
          Mv::Core::Migration::Base.execute()
        end
      end
    end
  end
end