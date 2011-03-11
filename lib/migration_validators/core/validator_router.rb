module MigrationValidators
  module Core
    class ValidatorRouter 
      def initialize containers
        @containers = containers
        @routes = {}
      end

      def to container_name, conditions = {}
        raise "Container name is undefined" if container_name.blank?

        @routes[container_name] ||= conditions[:if]
      end

      def add_validators validators
        process(validators) do |container, filtered_validators|
          container.add_validators(filtered_validators)
        end
      end
      
      def remove_validators validators
        process(validators) do |container, filtered_validators|
          container.remove_validators(filtered_validators)
        end
      end

      private

      def process validators
        @routes.inject([]) do |res, (container_name, conditions)| 
          filtered_validators = validators.select {|validator| validator.satisfies(conditions)}

          unless filtered_validators.blank?
            container = @containers[container_name]
            raise MigrationValidators::MigrationValidatorsException.new("Routing error. Contianer #{container_name} is not defined.") if container.nil?

            res.concat(yield(container, filtered_validators))
          end

          res
        end
      end
    end
  end
end
