module Mv
  module Core
    module Constraints
      class Description
        attr_reader :name, :type, :options

        def initialize name, type, options = {}
          @name = name
          @type = type
          @options = options
        end

        def ==(description)
          description &&
          description.name.to_s == name.to_s &&
          description.type.to_s == type.to_s &&
          description.options.length == options.length &&
          description.options.all?{ |key, value|
            options.with_indifferent_access[key].to_s == value.to_s
          }
        end

        def to_a
          [name, type, options]
        end

        def <=> other_info
          to_a <=> other_info.to_a 
        end
      end
    end
  end
end