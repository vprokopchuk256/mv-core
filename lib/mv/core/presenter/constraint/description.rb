module Mv
  module Core
    module Presenter
      module Constraint
        class Description
          attr_reader :description

          delegate :name, :type, :options, to: :description

          def initialize(description)
            @description = description
          end

          def to_s
            params = [
              "\"#{name}\"", 
              options.collect{|key, value| "#{key}: :#{value}"}
            ].flatten.join(', ')

            "#{type}(#{params})"
          end
        end
      end
    end
  end
end