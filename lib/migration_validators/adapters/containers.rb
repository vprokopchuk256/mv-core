module MigrationValidators
  module Adapters
    module Containers
      def self.included(base)
        base.extend ClassMethods
      end

      module ClassMethods
        def containers
          @containers ||= {}
        end

        def container name, &block
          raise "Container name is not defined" if name.blank?

          container = containers[name] ||= MigrationValidators::Core::ValidatorContainer.new(validators, syntax)
          container.instance_eval(&block) if block
          container
        end

        def define_base_containers
          container :insert_trigger do
            group do |validator|
              trigger_name = (validator.options && validator.options[:insert_trigger_name]) || "trg_mgr_validates_#{validator.table_name}_ins"
              [validator.table_name, trigger_name]
            end

            operation :create do |stmt, group_name|
              table_name, trigger_name = group_name

              "CREATE TRIGGER #{trigger_name} BEFORE INSERT ON #{table_name} FOR EACH ROW
               BEGIN
                #{stmt};
               END;"
            end

            operation :drop do |stmt, group_name|
              table_name, trigger_name = group_name

              "DROP TRIGGER IF EXISTS #{trigger_name};"
            end

            operation :join do |stmt, value|
              [stmt, value].delete_if(&:blank?).join(";\n")
            end

            operation :db_name do |value|
              "NEW.#{value}"
            end

          end

          container :update_trigger do
            group do |validator|
              trigger_name = (validator.options && validator.options[:update_trigger_name]) || "trg_mgr_validates_#{validator.table_name}_upd"
              [validator.table_name, trigger_name]
            end

            operation :create do |stmt, group_name|
              table_name, trigger_name = group_name

              "CREATE TRIGGER #{trigger_name} BEFORE UPDATE ON #{table_name} FOR EACH ROW
               BEGIN
                #{stmt};
               END;"
            end

            operation :drop do |stmt, group_name|
              table_name, trigger_name = group_name

              "DROP TRIGGER IF EXISTS #{trigger_name};"
            end

            operation :join do |stmt, value|
              [stmt, value].delete_if(&:blank?).join(";\n")
            end

            operation :db_name do |value|
              "NEW.#{value}"
            end
          end

          container :check do
            group do |validator|
              check_name = (validator.options && validator.options[:check_name]) || "chk_#{validator.table_name}_#{validator.column_name}"
              [validator.table_name, check_name]
            end

            operation :create do |stmt, group_name|
              table_name, check_name = group_name
              "ALTER TABLE #{table_name} ADD CONSTRAINT #{check_name} CHECK(#{stmt});"
            end

            operation :drop do |stmt, group_name|
              table_name, check_name = group_name
              "ALTER TABLE #{table_name} DROP CONSTRAINT #{check_name};"
            end
          end
        end
      end
    end
  end
end
