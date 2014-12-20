require 'mv/core/validation/factory'

module Mv
  module Core
    module Db
      class MigrationValidator < ::ActiveRecord::Base
        serialize :options, Hash
        serialize :constraints, Hash

        validates :table_name, presence: true
        validates :column_name, presence: true
        validates :validation_type, presence: true

        validate :validation_validity

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

        def validation_validity
          if (v = validation).invalid?
            v.errors.full_messages.each do |message|
              errors.add(:validation, message)
            end
          end
        end
      end
    end
  end
end