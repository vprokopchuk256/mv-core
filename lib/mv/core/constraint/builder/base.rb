require 'mv/core/validation/builder/factory'

module Mv
  module Core
    module Constraint
      module Builder
        class Base
          attr_reader :constraint

          delegate :name, to: :constraint

          def initialize(constraint)
            @constraint = constraint
          end

          def create
          end

          def delete
          end

          def update new_constraint_builder
          end

          def self.validation_builders_factory
            @validation_builders_factory ||= Mv::Core::Validation::Builder::Factory.new
          end

          protected

          def validation_builders
            @validation_builders ||= constraint.validations.collect do |validation|
              self.class.validation_builders_factory.create_builder(validation)
            end
          end

          def db
            ::ActiveRecord::Base.connection
          end
        end
      end
    end
  end
end