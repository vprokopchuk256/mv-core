require 'mv/core/error'
require_relative 'uniqueness'
require_relative 'exclusion'
require_relative 'inclusion'
require_relative 'length'
require_relative 'presence'
require_relative 'absence'
require_relative 'custom'

module Mv
  module Core
    module Validation
      class Factory
        include Singleton

        def create_validation table_name, column_name, validation_type, opts
          validation_class = factory_map[validation_type.to_sym]

          raise Mv::Core::Error.new(table_name: table_name,
                                    column_name: column_name,
                                    validation_type: validation_type,
                                    opts: opts,
                                    error: "Validation '#{validation_type}' is not supported") unless validation_class

          validation_class.new(table_name, column_name, opts)
        end

        def register_validation validation_type, klass
          factory_map[validation_type.to_sym] = klass
        end

        def register_validations opts
          opts.each do |validation_type, klass|
            register_validation(validation_type, klass)
          end
        end

        def registered_validations
          factory_map.keys
        end

        class << self
          delegate :create_validation,
                   :registered_validations,
                   :register_validation,
                   :register_validations, to: :instance
        end

        private

        def factory_map
          @factory_map ||= {
            uniqueness: Mv::Core::Validation::Uniqueness,
            exclusion: Mv::Core::Validation::Exclusion,
            inclusion: Mv::Core::Validation::Inclusion,
            length: Mv::Core::Validation::Length,
            presence: Mv::Core::Validation::Presence,
            absence: Mv::Core::Validation::Absence,
            custom: Mv::Core::Validation::Custom
          }
        end
      end
    end
  end
end
