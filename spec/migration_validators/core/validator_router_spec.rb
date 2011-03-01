require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MigrationValidators::Core::ValidatorRouter, :type => :mv_test  do
  before :all do
    use_memory_db
    db.initialize_schema_migrations_table
  end

  before :each do
    @builder = MigrationValidators::Core::StatementBuilder.new

    @builder.action :and do |stmt, value|
      "#{stmt} AND #{value}"
    end

    @builder.action :or do |stmt, value|
      "#{stmt} OR #{value}"
    end

    @definition = MigrationValidators::Core::ValidatorDefinition.new @builder

    @definition.property :property_name do |property_value|
      column
    end

    @container = MigrationValidators::Core::ValidatorContainer.new :validator_name => @definition
    @container.action :create do |stmt, group_name|    
      "CREATE ENTITY #{group_name} BEGIN #{stmt} END"
    end

    @container_1 = MigrationValidators::Core::ValidatorContainer.new :validator_name => @definition
    @container_1.action :create do |stmt, group_name|    
      "CREATE ENTITY_1 #{group_name} BEGIN #{stmt} END"
    end

    @router = MigrationValidators::Core::ValidatorRouter.new :container => @container, :container_1 => @container_1
  end

  it "routes validators according to their properties" do
    validator1 = Factory.build :db_validator, :validator_name => :validator_name, :options => {:property_name => :property_value, :on => :create}
    validator2 = Factory.build :db_validator, :validator_name => :validator_name, :options => {:property_name => :property_value, :on => :update}

    @router.to :container, :if => {:on => :create}
    @router.to :container_1, :if => {:on => :update}
    
    @router.process([validator1, validator2]).should == ["CREATE ENTITY #{validator1.name} BEGIN #{validator1.column_name} END",
                                                         "CREATE ENTITY_1 #{validator2.name} BEGIN #{validator2.column_name} END"]
  end


end
