require 'mv/core/db/migration_validator'

FactoryGirl.define do
  factory :migration_validator, class: Mv::Core::Db::MigrationValidator do
    table_name     :table_name 
    column_name    :column_name
    validator_name :uniqueness
    constraints({ trg_table_name_update: :trigger })
    options({ as: :trigger })
  end
end