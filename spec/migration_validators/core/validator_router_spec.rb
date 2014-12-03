# require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

# describe MigrationValidators::Core::ValidatorRouter, :type => :mv_test  do
#   let(:builder) { MigrationValidators::Core::StatementBuilder.new }
#   let(:definition) { MigrationValidators::Core::ValidatorDefinition.new builder }
#   let(:container) { MigrationValidators::Core::ValidatorContainer.new :container, :validator_name => definition, :validator_name_1 => definition }
#   let(:container_1) { MigrationValidators::Core::ValidatorContainer.new :container, :validator_name => definition }
#   let(:router) { MigrationValidators::Core::ValidatorRouter.new :container => container, :container_1 => container_1 }

#   before :all do
#     use_memory_db
#     db.initialize_schema_migrations_table
#   end

#   before :each do
#     builder.operation :and do |stmt, value|
#       "#{stmt} AND #{value}"
#     end

#     builder.operation :or do |stmt, value|
#       "#{stmt} OR #{value}"
#     end

#     definition.property :property_name do |property_value|
#       column
#     end

#     container.operation :create do |stmt, group_name|    
#       "CREATE ENTITY #{group_name} BEGIN #{stmt} END"
#     end

#     container_1.operation :create do |stmt, group_name|    
#       "CREATE ENTITY_1 #{group_name} BEGIN #{stmt} END"
#     end
#   end

#   context "routes validators according to their properties" do
#     let(:validator1) { FactoryGirl.build :db_validator, :validator_name => :validator_name, :options => {:property_name => :property_value, :on => :create} }
#     let(:validator2) { FactoryGirl.build :db_validator, :validator_name => :validator_name, :options => {:property_name => :property_value, :on => :update} }

#     before do
#       router.to :container, :if => {:on => :create}
#       router.to :container_1, :if => {:on => :update}
#     end

#     subject{ router.add_validators([validator1, validator2]) }
    
#     it { is_expected.to eq(["CREATE ENTITY #{validator1.name} BEGIN #{validator1.column_name} END", "CREATE ENTITY_1 table_15_column_name_1_validator_name BEGIN column_name_1 END"]) }
#   end

#   context "merges routes to the same container" do
#     let(:validator1) { FactoryGirl.build :db_validator, :table_name => :table_name, :validator_name => :validator_name, :options => {:property_name => :property_value, :on => :create} }
#     let(:validator2) { FactoryGirl.build :db_validator, :table_name => :table_name, :validator_name => :validator_name_1, :options => {:property_name => :property_value, :on => :create} }

#     before do
#       container.group {|validator| validator.table_name}
#       container.constraint_name {|group_name| "trigger_name" }
#       router.to :container, :if => {:on => :create}
#     end

#     subject{ router.add_validators([validator1, validator2]) }
    
#     it { is_expected.to eq(["CREATE ENTITY trigger_name BEGIN #{validator1.column_name} JOIN #{validator2.column_name} END"]) }
#   end
# end
