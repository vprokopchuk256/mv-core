require 'mv/core/validation/uniqueness'
require 'mv/core/validation/exclusion'
require 'mv/core/validation/format'
require 'mv/core/validation/inclusion'
require 'mv/core/validation/length'
require 'mv/core/validation/presence'

module Mv
  module Core
    module Validation
      class Factory
        include Singleton

        def create_validation table_name, column_name, type, opts
          factroy_map[type.to_sym].new(table_name, column_name, opts)
        end 

        class << self
          delegate :create_validation, to: :instance
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