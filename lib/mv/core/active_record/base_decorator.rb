require 'mv/core/validation/active_model_presenter/factory'

module Mv
  module Core
    module ActiveRecord
      module BaseDecorator
        def self.included(base)
          Mv::Core::Db::MigrationValidator.where(table_name: base.table_name).each do |validator|
            presenter = Mv::Core::Validation::ActiveModelPresenter::Factory.create_presenter(validator.validation)

            base.validates(presenter.column_name, presenter.options) if presenter
          end
        end

        def enforce_migration_validations
          include BaseDecorator
        end
      end
    end
  end
end