require 'mv/core/db/migration_validator'
require 'mv/core/router'
require 'mv/core/constraint/factory'

module Mv
  module Core
    module Services
      class LoadConstraints
        attr_reader :tables

        def initialize(tables)
          @tables = tables
        end

        def execute
          res = []

          Mv::Core::Db::MigrationValidator.where(table_name: tables).each do |migration_validator|
            validation = migration_validator.validation
            descriptions = Mv::Core::Router.route(validation)

            descriptions.each do |description|
              add_constraint(res, description).validations << validation
            end
          end

          return res
        end

        private

        def factory
          @factory ||= Mv::Core::Constraint::Factory.new
        end

        def add_constraint(constraints_list, description)
          res = constraints_list.find{|constraint| constraint.description == description}

          unless res
            res = factory.create_constraint(description)
            constraints_list << res
          end

          res
        end
      end
    end
  end
end