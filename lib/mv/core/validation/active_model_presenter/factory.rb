require_relative 'exclusion'
require_relative 'inclusion'
require_relative 'length'
require_relative 'presence'
require_relative 'absence'
require_relative 'uniqueness'

module Mv
  module Core
    module Validation
      module ActiveModelPresenter
        class Factory
          include Singleton

          def create_presenter validation
            klass = factory_map[validation.class]

            klass.new(validation) if klass
          end

          def register_presenter validation_class, presenter_class
            factory_map[validation_class] = presenter_class
          end

          def register_presenters opts
            opts.each do |validation_class, presenter_class|
              register_presenter(validation_class, presenter_class)
            end
          end

          class << self
            delegate :create_presenter, :register_presenter, :register_presenters, to: :instance
          end

          private

          def factory_map
            @factory_map ||= {
              Mv::Core::Validation::Exclusion => Mv::Core::Validation::ActiveModelPresenter::Exclusion,
              Mv::Core::Validation::Inclusion => Mv::Core::Validation::ActiveModelPresenter::Inclusion,
              Mv::Core::Validation::Length => Mv::Core::Validation::ActiveModelPresenter::Length,
              Mv::Core::Validation::Presence => Mv::Core::Validation::ActiveModelPresenter::Presence,
              Mv::Core::Validation::Absence => Mv::Core::Validation::ActiveModelPresenter::Absence,
              Mv::Core::Validation::Uniqueness => Mv::Core::Validation::ActiveModelPresenter::Uniqueness,
            }
          end
        end
      end
    end
  end
end
