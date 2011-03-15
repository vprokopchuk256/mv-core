require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MigrationValidators::Core::ValidatorContainer, :type => :mv_test  do
  before :all do
    use_memory_db
    db.initialize_schema_migrations_table
  end

  before :each do
    MigrationValidators::Core::DbValidator.clear_all

    db.drop_table :test_table if db.table_exists?(:test_table)
    db.create_table :test_table do |t|
      t.string :str_column
      t.string :str_column_1
    end

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

    @container = MigrationValidators::Core::ValidatorContainer.new :container, :validator_name => @definition
    @validator = Factory.build :db_validator, 
                               :validator_name => :validator_name,
                               :column_name => :column_name,
                               :options => {:property_name => :property_value}

  end

  describe :remove_validators do
    it "regenerates constraint without specified validators" do
    end
  end

  describe :add_validators do
    it "returns definition processing result by default" do
      @container.add_validators([@validator]).should == ["column_name AND property_value"]
    end

    it "adds constraint name to processed validators constraint list" do
      @container.constraint_name {|group_key| "constraint" }
      @container.add_validators([@validator]).should == ["column_name AND property_value"]

      @validator.in_constraint?("constraint").should be_true
    end

    it "joins specified validator to existing ones within the same constraint" do
      @container.constraint_name {|group_key| "constraint" }

      validator1 = Factory.create :db_validator, 
                                  :validator_name => :validator_name,
                                  :table_name => :test_table, 
                                  :column_name => :str_column,
                                  :options => {:property_name => :property_value_1}, 
                                  :constraints => ["constraint"]

      @container.add_validators([@validator]).should == ["column_name AND property_value JOIN str_column AND property_value_1"]
    end

    it "creates drop statement if defined" do
      @container.constraint_name {|group_key| "constraint" }

      @container.operation :drop do |stmt, constraint_name, group_name|    
        "DROP ENTITY #{constraint_name}"
      end

      validator1 = Factory.create :db_validator, 
                                  :validator_name => :validator_name,
                                  :table_name => :test_table, 
                                  :column_name => :str_column,
                                  :options => {:property_name => :property_value_1}, 
                                  :constraints => ["constraint"]

      @container.add_validators([@validator]).should == ["DROP ENTITY constraint", "column_name AND property_value JOIN str_column AND property_value_1"]
    end

    #it "do not creates drop statement if such constraint does not exist" do
    #  @container.constraint_name {|group_key| "constraint" }

    #  @container.operation :drop do |stmt, constraint_name, group_name|    
    #    "DROP ENTITY #{constraint_name}"
    #  end

    #  @container.add_validators([@validator]).should == ["column_name AND property_value"]
    #end
  end

  describe :remove_validators do
    it "regenerates constraint without specified validators" do
      @container.constraint_name {|group_key| "constraint" }

      validator1 = Factory.create :db_validator, 
                                  :validator_name => :validator_name,
                                  :table_name => :test_table, 
                                  :column_name => :str_column,
                                  :options => {:property_name => :property_value_1}, 
                                  :constraints => ["constraint"]

      validator2 = Factory.create :db_validator, 
                                  :validator_name => :validator_name,
                                  :table_name => :test_table, 
                                  :column_name => :str_column_1,
                                  :options => {:property_name => :property_value_2}, 
                                  :constraints => ["constraint"]

      @container.remove_validators([validator2]).should == ["str_column AND property_value_1"]
    end
  end
end
