require 'mv/core/constraint/builder/index'
require 'mv/core/constraint/builder/trigger'

module Mv
  module Core
    module Constraint
      module Builder
        class Factory
          include Singleton

          def create_builder constraint
            factory_map[constraint.class].new(constraint)
          end

          def register_builder constraint_class, builder_class
            factory_map[constraint_class] = builder_class
          end

          class << self
            delegate :create_builder, :register_builder, to: :instance
          end


          private

          def factory_map
            @factory_map ||= {
              Mv::Core::Constraint::Index => Mv::Core::Constraint::Builder::Index, 
              Mv::Core::Constraint::Trigger => Mv::Core::Constraint::Builder::Trigger
            }
          end
        end
      end
    end
  end
end