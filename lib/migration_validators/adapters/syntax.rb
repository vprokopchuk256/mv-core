module MigrationValidators
  module Adapters
    module Syntax
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def syntax &block
          @builder ||= MigrationValidators::Core::StatementBuilder.new
          @builder.instance_eval(&block) if block
          @builder
        end
      end
    end
  end
end
