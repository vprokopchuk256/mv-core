require 'mv/core/validation/factory'
require 'mv/core/constraint/description'
require 'mv/core/validators/valid_validator'

module Mv
  module Core
    module Db
      class MigrationValidator < ::ActiveRecord::Base
        serialize :options, Hash

        validates :table_name, presence: true
        validates :column_name, presence: true
        validates :validation_type, presence: true

        validates :validation, valid: true

        def validation
          validation_factory.create_validation(table_name, 
                                               column_name, 
                                               validation_type, 
                                               options)
        end

        private

        def validation_factory
          @validation_factory ||= Mv::Core::Validation::Factory.new
        end 
      end
    end
  end
end