require_relative 'trigger'
require_relative 'index'

module Mv
  module Core
    module Constraint
      class Factory
        include Singleton

        def create_constraint description
          factory_map[description.type.to_sym].new(description)
        end

        def register_constraint type, klass
          factory_map[type.to_sym] = klass
        end

        class << self
          delegate :create_constraint, :register_constraint, to: :instance
        end

        private

        def factory_map
          @factory_map ||= {
            trigger: Mv::Core::Constraint::Trigger,
            index: Mv::Core::Constraint::Index
          }
        end
      end
    end
  end
end
