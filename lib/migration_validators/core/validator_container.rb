# module MigrationValidators
#   module Core
#     class ValidatorContainer < StatementBuilder
#       attr_reader :name

#       def initialize name, definitions, builder = nil
#         super "", builder

#         @name = name
#         @definitions = definitions

#         group do |validator|
#           validator.name
#         end

#         constraint_name do |group_key|
#           group_key.to_s
#         end

#         operation :create do |stmt, group_name|
#           stmt
#         end

#         operation :drop do
#           ""
#         end

#         operation :join do |stmt, stmt_1|
#           [stmt, stmt_1].delete_if(&:blank?).join(" JOIN ")
#         end
#       end

#       def group &block
#         @group_proc = block
#       end

#       def constraint_name &block
#         @constraint_name_proc = block
#       end

#       def add_validators validators
#         res, constraint_name = process_validators(validators) do |existing_validators|
#           validators + existing_validators
#         end

#         validators.each {|validator| validator.constraints.add(constraint_name) }

#         res
#       end

#       def remove_validators validators
#         res, constraint_name = process_validators(validators) do |existing_validators|
#           existing_validators - validators
#         end

#         validators.each {|validator| validator.constraints.remove(constraint_name) }

#         res
#       end

#       private

#       def process_validators validators
#         validators.group_by(&@group_proc).inject([]) do |res, (group_name, group)|
#           constraint_name = @constraint_name_proc.call(group_name)
#           constraint_validators = MigrationValidators::Core::DbValidator.constraint_validators(constraint_name)

#           group = yield(constraint_validators).uniq

#           stmt = drop_group(constraint_name, group_name)
#           res << stmt unless stmt.blank?

#           unless group.blank?
#             stmt = create_group(constraint_name, group_name, group) 
#             res << stmt unless stmt.blank?
#           end
#           [res, constraint_name]
#         end
#       end

#       def isolate 
#         clear!
#         yield if block_given?
#         res = self.to_s
#         clear!
#         res
#       end

#       def drop_group constraint_name, group_name
#         isolate { drop(constraint_name, group_name) }
#       end

#       def create_group constraint_name, group_name, group
#         isolate do
#           group.each do |validator|
#             definition = @definitions[validator.validator_name.to_s] || @definitions[validator.validator_name.to_sym]

#             raise MigrationValidators::MigrationValidatorsException.new("Validator defintion for #{validator.validator_name} is not defined.") unless definition

#             definition.clone(self).process(validator).each do |statement|
#               join(statement)
#             end
#           end
          
#           create(constraint_name, group_name) unless group.blank?
#         end
#       end
#     end 
#   end
# end
