require 'mv/core/validation/factory'

module Mv
  module Core
    module Services
      class ParseValidationOptions
        attr_reader :opts

        def initialize(opts)
          @opts = opts || {}
        end

        def execute
          validates = opts.delete(:validates) || opts.delete("validates")

          return validates if validates.is_a?(Hash)
          return { custom: validates } if validates.present?

          Mv::Core::Validation::Factory.registered_validations.inject({}) do |res, validation_type|
            validation_options = opts.delete(validation_type.to_sym) || opts.delete(validation_type.to_s)
            res[validation_type] = validation_options if validation_options
            res
          end
        end
      end
    end
  end
end