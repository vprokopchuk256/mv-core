require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MigrationValidators::Core::ValidatorContainer, :type => :mv_test  do
  before :all do
    use_memory_db
    db.initialize_schema_migrations_table
  end

  before :each do
    @builder = MigrationValidators::Core::StatementBuilder.new

    @builder.operation :and do |stmt, value|
      "#{stmt} AND #{value}"
    end

    @builder.operation :or do |stmt, value|
      "#{stmt} OR #{value}"
    end

    @definition = MigrationValidators::Core::ValidatorDefinition.new @builder

    @definition.property :property_name do |property_value|
      column.and(property_value)
    end

    @container = MigrationValidators::Core::ValidatorContainer.new :validator_name => @definition
    @validator = Factory.build :db_validator, 
                               :validator_name => :validator_name,
                               :column_name => :column_name,
                               :options => {:property_name => :property_value}

  end

  describe :process do
    it "returns definition processing result by default" do
      @container.process([@validator]).should == ["column_name AND property_value"]
    end

    it "allows to define create template" do
      @container.operation :create do |stmt, group_name|    
        "CREATE ENTITY #{group_name} BEGIN #{stmt}; END"
      end

      @container.process([@validator]).should == ["CREATE ENTITY #{@validator.name} BEGIN column_name AND property_value; END"]
    end

    it "allows to define drop tempalte" do
      @container.operation :drop do |stmt, group_name|    
        "DROP ENTITY #{group_name};"
      end

      @container.process([@validator]).should == ["DROP ENTITY #{@validator.name};", "column_name AND property_value"]
    end

    it "joins with JOIN statements from the same group by default" do
      @container.process([@validator, @validator]).should == ["column_name AND property_value JOIN column_name AND property_value"]
    end

    it "separates statements for validators from different groups" do
      validator1 = Factory.build :db_validator, 
                                 :validator_name => :validator_name,
                                 :column_name => :column_name_1,
                                 :options => {:property_name => :property_value_1}

      @container.process([@validator, validator1]).should == ["column_name AND property_value", "column_name_1 AND property_value_1"]
    end
  end
  
end
