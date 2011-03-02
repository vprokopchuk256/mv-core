module MigrationValidators
  module Core
    class ValidatorContainer < StatementBuilder
      def initialize definitions, builder = nil
        super "", builder

        @definitions = definitions

        group do |validator|
          validator.name
        end

        operation :create do |stmt, group_name|
          stmt
        end

        operation :drop do
          ""
        end

        operation :join do |stmt, stmt_1|
          [stmt, stmt_1].delete_if(&:blank?).join(" JOIN ")
        end
      end

      def group &block
        @group_proc = block
      end

      def process validators
        validators.group_by(&@group_proc).inject([]) do |res, (group_name, group)|
          stmt = drop_group(group_name)
          res << stmt unless stmt.blank?

          stmt = create_group(group_name, group)
          res << stmt unless stmt.blank?
        end
      end

      private

      def isolate 
        clear!
        yield if block_given?
        res = self.to_s
        clear!
        res
      end

      def drop_group group_name
        isolate { drop(group_name) }
      end

      def create_group group_name, group
        isolate do
          group.each do |validator|
            definition = @definitions[validator.validator_name]

            raise MigrationValidators::MigrationValidatorsException.new("Validator defintion for #{validator.validator_name} is not defined.") unless definition

            definition.clone(self).process(validator).each do |statement|
              join(statement)
            end
          end
          
          create(group_name)
        end
      end
    end 
  end
end
