require_relative 'exclusion'
require_relative 'inclusion'
require_relative 'length'
require_relative 'presence'
require_relative 'absence'
require_relative 'uniqueness'
require_relative 'custom'

module Mv
  module Core
    module Validation
      module Builder
        class Factory
          def create_builder validation
            factory_map[validation.class].new(validation)
          end

          def register_builder validation_class, builder_class
            factory_map[validation_class] = builder_class
          end

          def register_builders opts
            opts.each do |validation_class, builder_class|
              register_builder(validation_class, builder_class)
            end
          end

          private

          def factory_map
            @factory_map ||= {
              Mv::Core::Validation::Exclusion => Mv::Core::Validation::Builder::Exclusion,
              Mv::Core::Validation::Inclusion => Mv::Core::Validation::Builder::Inclusion,
              Mv::Core::Validation::Length => Mv::Core::Validation::Builder::Length,
              Mv::Core::Validation::Presence => Mv::Core::Validation::Builder::Presence,
              Mv::Core::Validation::Absence => Mv::Core::Validation::Builder::Absence,
              Mv::Core::Validation::Uniqueness => Mv::Core::Validation::Builder::Uniqueness,
              Mv::Core::Validation::Custom => Mv::Core::Validation::Builder::Custom
            }
          end
        end
      end
    end
  end
end
