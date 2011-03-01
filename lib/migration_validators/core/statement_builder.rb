module MigrationValidators
  module Core
    class StatementBuilder
      attr_reader :actions

      def initialize value = "", builder = nil
        @stmt = value
        @actions = builder ? builder.actions.clone : {}
      end

      def to_s
        @stmt
      end

      def action name, &block
        @actions[name.to_s] = block if block
      end

      def merge! builder
        @actions.merge!(builder.actions) if builder
      end

      alias_method :old_method_missing, :method_missing
      def method_missing method_name, *args
        call_action(method_name, *args) || old_method_missing(method_name, *args)
      end

      protected
      

      attr_accessor :stmt

      def clear! 
        @stmt = ""
      end

      def change *args, &block
        @stmt = instance_exec(*args, &block).to_s
      end

      private

      def call_action action_name, *args
        block = @actions[action_name.to_s]

        if (block)
          change(@stmt, *args, &block)
          return self
        end

        return nil
      end

    end
  end
end
