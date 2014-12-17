module Mv
  module Core
    module Constraints
      class ContainerInfo
        attr_reader :name, :type, :options

        def initialize name, type, options = {}
          @name = name
          @type = type
          @options = options
        end

        def ==(container_info)
          container_info &&
          container_info.name.to_s == name.to_s &&
          container_info.type.to_s == type.to_s &&
          container_info.options.length == options.length &&
          container_info.options.all?{ |key, value|
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