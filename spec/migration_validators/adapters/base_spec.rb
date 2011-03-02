require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MigrationValidators::Adapters::Base, :type => :mv_test do
  before :all do
    Driver = Class.new(MigrationValidators::Adapters::Base)
    use_memory_db
    db.initialize_schema_migrations_table
  end

  before :each do
    @validator = Factory.build :db_validator, 
                               :validator_name => :validator_name, 
                               :table_name => :table_name, 
                               :column_name => :column_name,
                               :options => {:property_name => :property_value}

    Driver.syntax do 
      operation :some_interesting_operation do |stmt, value| 
        "#{stmt} SOME_INTERESTING_OPERATION #{value}"
      end
    end

    Driver.validator :validator_name do
      property :property_name do |property_value|
        column.some_interesting_operation(property_value)
      end
    end

    Driver.container :container_name do
      operation :some_interesting_operation do |stmt, value| 
        "#{stmt} SOME_INTERESTING_CONTAINER_OPERATION #{value}"
      end
    end
  end

  describe :syntax do
    it "allows to define basic operations syntax" do
      Driver.syntax.some_interesting_operation(:value).to_s.should == " SOME_INTERESTING_OPERATION value"
    end
  end

  describe :validator do
    it "allows to define validator definition" do
      Driver.validators[:validator_name].should_not be_blank
      Driver.validators[:validator_name].process(@validator).should == ["column_name SOME_INTERESTING_OPERATION property_value"]
    end
  end

  describe :container do
    it "allows to define validator definition" do
      Driver.containers[:container_name].should_not be_blank
      Driver.containers[:container_name].process([@validator]).should == ["column_name SOME_INTERESTING_CONTAINER_OPERATION property_value"]
    end
  end

  describe :route do
    before :each do
      Driver.clear_routing
    end

    it "allows to define routing method" do
      Driver.route :validator_name, :container do
        to :container_name
      end

      Driver.public_instance_methods.include?(:validate_validator_name_container).should be_true
      Driver.public_instance_methods.include?(:remove_validate_validator_name_container).should be_true
      Driver.public_instance_methods.include?(:validate_validator_name).should be_false
      Driver.public_instance_methods.include?(:remove_validate_validator_name).should be_false
    end

    it "allows to deny remove method" do
      Driver.route :validator_name, :container, :remove => false do
        to :container_name
      end

      Driver.public_instance_methods.include?(:remove_validate_validator_name_container).should be_false
    end

    it "allows to define default methods" do
      Driver.route :validator_name, :container, :default => true  do
        to :container_name
      end

      Driver.public_instance_methods.include?(:validate_validator_name).should be_true
      Driver.public_instance_methods.include?(:remove_validate_validator_name).should be_true
    end
  end
end
