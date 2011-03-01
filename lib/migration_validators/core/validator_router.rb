module MigrationValidators
  module Core
    class ValidatorRouter 
      def initialize containers
        @containers = containers
        @routes = {}
      end

      def to container_name, conditions
        @routes[container_name] ||= conditions[:if]
      end

      def process validators
        @routes.inject([]) do |res, (container_name, conditions)| 
          filtered_validators = validators.select {|validator| validator.satisfies(conditions)}

          next if filtered_validators.blank?

          container = @containers[container_name]

          raise MigrationValidators::MigrationValidatorsException.new("Routing error. Contianer #{container_name} is not defined.") if container.blank?

          res.concat(container.process(filtered_validators))
          res
        end
      end
    end
  end
end
