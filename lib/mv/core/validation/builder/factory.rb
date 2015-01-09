require 'mv/core/validation/builder/exclusion'
require 'mv/core/validation/builder/inclusion'
require 'mv/core/validation/builder/length'
require 'mv/core/validation/builder/presence'
require 'mv/core/validation/builder/uniqueness'

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
              Mv::Core::Validation::Uniqueness => Mv::Core::Validation::Builder::Uniqueness
            }
          end
        end
      end
    end
  end
end