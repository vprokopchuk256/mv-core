module Mv
  module Core
    module Presenter
      class MigrationValidator
        attr_reader :validator

        delegate :validation_type, :options, to: :validator

        def initialize(validator)
          @validator = validator
        end

        def to_s
          "#{validation_type}: { #{options_str} } ".squish
        end

        private

        def options_str
          options.collect do |key, value|
            "#{key}: #{value_to_str(value)}"
          end.join(', ')
        end

        def value_to_str value
          return ":#{value}" if value.is_a?(Symbol)
          return time_to_str(value) if value.is_a?(Time)
          return datetime_to_str(value) if value.is_a?(DateTime)
          return date_to_str(value) if value.is_a?(Date)
          return range_to_str(value) if value.is_a?(Range)
          return array_to_str(value) if value.is_a?(Array)
          return "'#{value}'" if value.is_a?(String)
          return "/#{value.source}/" if value.is_a?(Regexp)
          value.to_s
        end

        def array_to_str value
          "[#{value.collect{ |value| value_to_str(value) }.join(', ')}]"
        end

        def range_to_str value
          [
            value_to_str(value.first), 
            value.exclude_end? ? '...' : '..', 
            value_to_str(value.last)
          ].join
        end

        def regexp_to_str value
        end

        def time_to_str value
          "Time.new(#{value.strftime("%Y, %-m, %-d, %-H, %-M, %-S, '%:z'")})"
        end

        def datetime_to_str value
          "DateTime.new(#{value.strftime("%Y, %-m, %-d, %-H, %-M, %-S, '%:z'")})"
        end

        def date_to_str value
          "Date.new(#{value.strftime("%Y, %-m, %-d")})"
        end
      end
    end
  end
end