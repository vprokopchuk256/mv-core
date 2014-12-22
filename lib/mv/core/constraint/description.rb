module Mv
  module Core
    module Constraint
      class Description
        include Comparable

        attr_reader :name, :type, :options

        def initialize name, type, options = {}
          @name = name.to_sym
          @type = type.to_sym
          @options = options.inject({}) do |res, (name, value)|
            res[name.to_sym] = value.to_s
            res
          end
        end

        def <=> other_info
          [name, type, options] <=> [other_info.name, other_info.type, other_info.options]
        end
      end
    end
  end
end