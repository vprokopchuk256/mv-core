require 'mv/core/validation/uniqueness'
require 'mv/core/validation/exclusion'
require 'mv/core/validation/format'
require 'mv/core/validation/inclusion'
require 'mv/core/validation/length'
require 'mv/core/validation/presence'
require 'mv/core/error'

module Mv
  module Core
    module Validation
      class Factory
        include Singleton

        def create_validation table_name, column_name, validation_type, opts
          validation_class = factroy_map[validation_type.to_sym]

          raise Mv::Core::Error.new(table_name: table_name, 
                                    column_name: column_name, 
                                    validation_type: validation_type, 
                                    opts: opts) unless validation_class

          validation_class.new(table_name, column_name, opts)
        end 

        def register_validation validation_type, klass
          factroy_map[validation_type.to_sym] = klass
        end

        class << self
          delegate :create_validation, :register_validation, to: :instance
        end

        private 

        def factroy_map
          @factory_map ||= {
            uniqueness: Mv::Core::Validation::Uniqueness, 
            exclusion: Mv::Core::Validation::Exclusion, 
            format: Mv::Core::Validation::Format, 
            inclusion: Mv::Core::Validation::Inclusion, 
            length: Mv::Core::Validation::Length, 
            presence: Mv::Core::Validation::Presence
          }
        end
      end
    end
  end
end