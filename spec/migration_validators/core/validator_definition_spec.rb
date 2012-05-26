require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MigrationValidators::Core::ValidatorDefinition, :type => :mv_test  do
  before :all do
    use_memory_db
    db.initialize_schema_migrations_table
  end

  before :each do
    @definition = MigrationValidators::Core::ValidatorDefinition.new  

    @definition.operation :and do |stmt, value|
      "#{stmt} AND #{value}"
    end

    @definition.operation :or do |stmt, value|
      "#{stmt} OR #{value}"
    end
  end

  it "might be initialized by db validator" do
    validator = FactoryGirl.build :db_validator

    @definition.validator = validator

    @definition.to_s.should == validator.column_name
  end
  
  describe "with validator" do
    before :each do
      @validator = FactoryGirl.build :db_validator
      @definition.validator = @validator
    end

    it "supports invariant column property" do
      @definition.column.and(@definition.column).to_s.should == "#{@validator.column_name} AND #{@validator.column_name}"
    end

    describe :process do
      before :each do
        @validator.options = { :property_name => :property_value }
      end

      it "returns empty array by default" do
        @definition.process(@validator).should == []
      end

      it "allows to define property handlers" do
        @definition.property :property_name do |property_value|
          "#{column.and(property_value)}"
        end
      
        @definition.process(@validator).should == ["#{@validator.column_name} AND property_value"]
      end

      it "allows to define post processors" do
        @definition.property :property_name do |property_value|
          "#{column.and(property_value)}"
        end

        @definition.post do
          self.and("some_post_value")
        end

        @definition.post :property_name => :property_value do
          self.and("some_post_value_1")
        end

        @definition.post "property_name" => :property_value do
          self.and("some_post_value_1")
        end

        @definition.post :property_name => :wrong_property_value do
          self.and("some_post_value_2")
        end

        @definition.process(@validator).should == ["#{@validator.column_name} AND property_value AND some_post_value AND some_post_value_1"]
      end

      it "allows to define default property handler" do
        @validator.options = {}

        @definition.property do |property_value|
          "#{column}"
        end

        @definition.process(@validator).should == ["#{@validator.column_name}"]
      end



      describe :bind_to_error do
        before :each do
          @definition.operation :bind_to_error do |stmt, error|
            "SHOW '#{error}' UNLESS (#{stmt})"
          end
        end

        it "takes :message validator property as default" do
          @validator.options[:message] = :default_message

          @definition.property :property_name do |property_value|
            "#{column.and(property_value)}"
          end

          @definition.process(@validator).should == ["SHOW 'default_message' UNLESS (#{@validator.column_name} AND property_value)"]
        end

        it "allows to define message mapping" do
          @validator.options[:message] = :default_message
          @validator.options[:specific_message] = :some_specific_message

          @definition.property :property_name, :message => :specific_message do |property_value|
            "#{column.and(property_value)}"
          end

          @definition.process(@validator).should == ["SHOW 'some_specific_message' UNLESS (#{@validator.column_name} AND property_value)"]
        end
      end

      it "allows to define options filter" do
        @validator.options[:property_name_1] = :property_value_1

        @definition.property(:property_name) {|property_value| "#{column.and(property_value)}"}
        @definition.property(:property_name_1) {|property_value| "#{column.and(property_value)}"}

        @definition.process(@validator, [:property_name]).should == ["#{@validator.column_name} AND property_value"]
      end
    end
  end
end
