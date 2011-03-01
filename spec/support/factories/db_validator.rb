Factory.sequence :validator_table_name do |n|
  "table_#{n}"
end

Factory.sequence :validator_column_name do |n|
  "column_name_#{n}"
end

Factory.define :db_validator, :class => MigrationValidators::Core::DbValidator do |validator|
  validator.table_name { Factory.next(:validator_table_name) }
  validator.column_name Factory.next(:validator_column_name)
  validator.validator_name 'presense'
end

Factory.define :db_validator_base, :parent => :db_validator do |validator|
  validator.table_name 'table_name'
  validator.column_name 'column_name'
end

Factory.define :uniqueness, :parent => :db_validator_base do |validator|
  validator.validator_name "uniqueness"
end

Factory.define :uniqueness_check, :parent => :uniqueness do |validator|
  validator.options  :as => :check
end

Factory.define :uniqueness_trigger, :parent => :uniqueness do |validator|
  validator.options  :as => :trigger
end

Factory.define :presense, :parent => :db_validator_base do |validator|
  validator.validator_name "presense"
end

Factory.define :presense_check, :parent => :presense do |validator|
  validator.options  :as => :check
end

Factory.define :presense_trigger, :parent => :presense do |validator|
  validator.options  :as => :trigger
end

