# module MigrationValidators
#   module Core
#     class AdapterWrapper
#       class AdapterCaller
#         def initialize adapter, action
#           @adapter = adapter
#           @action = action
#         end
        
#         def process validators
#           return if validators.blank?

#           check_validators(validators)

#           validators.group_by{|validator| [validator.table_name, compose_method_name(validator)]}.each do |group_id, group|
            
#             until group.blank?
#               handled_validators = @adapter.send(group_id.last, group)

#               break if handled_validators.blank?

#               group = group - handled_validators
#             end
#           end
#         end

#         private

#         def compose_method_name validator
#           method_suffix = validator.options.blank? || validator.options[:as].blank? ? "" : "_#{validator.options[:as]}"
#           :"#{@action}_#{validator.validator_name}#{method_suffix}"
#         end

#         def grep_public_instance_methods expr
#           @adapter.class.public_instance_methods.collect{|method| method.to_s.match(expr)}.compact.collect{|match| match[1]}
#         end

#         def supported_validators 
#           grep_public_instance_methods(/^#{@action}_([a-z]*)/).uniq
#         end

#         def supported_db_forms validator_name
#           grep_public_instance_methods(/^#{@action}_#{validator_name}_([a-z]*)/).uniq
#         end

#         def default_db_form_supported? validator_name
#           @adapter.class.method_defined? :"#{@action}_#{validator_name}"
#         end

#         def array2str array
#           "[" + array.collect {|elem| "'#{elem}'"}.join(',') + "]"
#         end

#         def check_validators validators
#           validators.each do |validator|

#             unless supported_validators.include?(validator.validator_name.to_s) 
#               raise MigrationValidatorsException.new("Adapter '#{@adapter.name}'. 'Action '#{@action}' for '#{validator.validator_name}' is not supported. Available validators: #{array2str(supported_validators)}")
#             end

#             if validator.options && (db_form = validator.options[:as]) 
#               unless supported_db_forms(validator.validator_name).include?(db_form.to_s)
#                 raise MigrationValidatorsException.new("Adapter '#{@adapter.name}'. Action '#{@action}' for db form '#{db_form}' for validator '#{validator.validator_name}' is not supported. Available db forms: #{array2str(supported_db_forms(validator.validator_name))}")
#               end
#             else
#               unless default_db_form_supported?(validator.validator_name.to_s)
#                 raise MigrationValidatorsException.new("Adapter '#{@adapter.name}'. 'Action '#{@action}' for '#{validator.validator_name}' with default db form is not supported")
#               end
#             end
#           end
#         end
#       end

#       def initialize adapter
#         @creator = AdapterCaller.new adapter, :validate
#         @remover = AdapterCaller.new adapter, :remove_validate
#       end

#       def create_validators validators
#         @creator.process validators
#       end

#       def remove_validators validators
#         @remover.process validators
#       end
#     end
#   end
# end
