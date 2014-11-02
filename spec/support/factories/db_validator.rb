FactoryGirl.define do

  sequence :validator_table_name do |n|
    "table_#{n}"
  end

  sequence :validator_column_name do |n|
    "column_name_#{n}"
  end

  factory :db_validator, :class => MigrationValidators::Core::DbValidator do |validator|
    validator.table_name { FactoryGirl.generate(:validator_table_name) }
    validator.column_name FactoryGirl.generate(:validator_column_name) 
    validator.validator_name 'presence'
  end

  factory :db_validator_base, :parent => :db_validator do |validator|
    validator.table_name 'table_name'
    validator.column_name 'column_name'
  end

  factory :uniqueness, :parent => :db_validator_base do |validator|
    validator.validator_name "uniqueness"
  end

  factory :uniqueness_check, :parent => :uniqueness do |validator|
    validator.options  :as => :check
  end

  factory :uniqueness_trigger, :parent => :uniqueness do |validator|
    validator.options  :as => :trigger
  end

  factory :presence, :parent => :db_validator_base do |validator|
    validator.validator_name "presence"
  end

  factory :presence_check, :parent => :presence do |validator|
    validator.options  :as => :check
  end

  factory :presence_trigger, :parent => :presence do |validator|
    validator.options  :as => :trigger
  end
end
