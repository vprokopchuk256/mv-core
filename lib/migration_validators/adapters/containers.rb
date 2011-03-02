module MigrationValidators
  module Adapters
    module Containers
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def containers to = nil
          @containers ||= {}

          return @containers unless to

          to = [to] unless to.kind_of?(Array)
        
          @containers.select {|container_name, container_value| to.include?(container_name)}
        end


        def container name, &block
          container = containers[name] ||= MigrationValidators::Core::ValidatorContainer.new(validators, syntax)
          container.instance_eval(&block) if block

          containers[name] = container
        end
      end
    end
  end
end
