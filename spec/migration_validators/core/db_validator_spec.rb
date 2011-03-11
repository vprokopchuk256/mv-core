require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


describe MigrationValidators::Core::DbValidator, :type => :mv_test do
  before :all do
    use_memory_db
    db.initialize_schema_migrations_table
  end

  before :each do
    MigrationValidators::Core::DbValidator.delete_all
    MigrationValidators::Core::DbValidator.rollback

    db.create_table(:table_name) do |t|
      t.string :column_name 
      t.string :column_name_1
      t.string :column_name_2
      t.string :column_name_3
      t.string :column_name_4
      t.string :column_name_5
      t.string :column_name_6
      t.string :column_name_7
      t.string :column_name_8
      t.string :column_name_9
      t.string :column_name_10
      t.string :column_name_11
    end unless db.table_exists?(:table_name)
  end

  subject do
    Factory.create :db_validator, :table_name => :table_name
  end

  it { should have_db_column(:table_name).of_type(:string).with_options(:length => 255, :null => false) }
  it { should validate_presence_of(:table_name) }
  it { should have_db_index(:table_name)}
  it { should ensure_length_of(:table_name).is_at_most(255) }

  it { should have_db_column(:column_name).of_type(:string).with_options(:length => 255, :null => true) }
  it { should ensure_length_of(:column_name).is_at_most(255) }


  it { should have_db_column(:options).of_type(:text)}
  it { should have_db_column(:constraints).of_type(:text)}
  
  
  it { should have_db_column(:validator_name).of_type(:string).with_options(:length => 255, :null => false) }
  it { should validate_presence_of(:validator_name) }
  it { should ensure_length_of(:validator_name).is_at_most(255) }

  it "should support read only name property composed of attributes" do
    validator =  Factory.create :db_validator, :table_name => :table_name

    validator.name.should == "#{validator.table_name}_#{validator.column_name}_#{validator.validator_name}"
  end

  describe "Error message" do
    it "is made of validator name, table_name and colum name if special message not defined" do
      validator =  Factory.build :db_validator, :table_name => :table_name

      validator.error_message.should == "#{validator.validator_name} violated for #{validator.table_name} field #{validator.column_name}"
    end

    it "might be re - defined" do
      validator =  Factory.build :db_validator, :table_name => :table_name, :options => {:message => "Custom message"}

      validator.error_message.should == 'Custom message'
    end
  end

  it "should support options serialization" do
    db_validator = Factory.build :db_validator, :table_name => :table_name

    db_validator.options = {:message => "some message"}

    db_validator.save!

    db_validator = MigrationValidators::Core::DbValidator.find(db_validator.id)

    db_validator.options[:message].should == "some message"
  end

  it "should support containers serialization" do
    db_validator = Factory.build :db_validator, :table_name => :table_name

    db_validator.constraints = [:some_constraint]

    db_validator.save!

    db_validator = MigrationValidators::Core::DbValidator.find(db_validator.id)

    db_validator.constraints.should == [:some_constraint]
  end


  describe "helper methods" do
    before :each do

      MigrationValidators::Core::DbValidator.add_column_validator "table_name", "column_name", "validator_name",  :option_name => :option_value
      MigrationValidators::Core::DbValidator.commit

      @db_validator = MigrationValidators::Core::DbValidator.first
    end

    describe "validators update operations" do
      describe :add_column_validator do
        describe "creates new record in the validators table" do
          it "with correct name" do
            @db_validator.name.should == "table_name_column_name_validator_name"
          end

          it "with correct table_name" do
            @db_validator.table_name.should == "table_name"
          end

          it "with correct column_name" do
            @db_validator.column_name.should == "column_name"
          end

          it "with correct validator_name" do
            @db_validator.validator_name.should == "validator_name"
          end

          it "with correct options" do
            @db_validator.options.length.should == 1
            @db_validator.options[:option_name].should == :option_value
          end
        end

        describe "checks table and column existence" do
          it "raises an error if table does not exists" do
            lambda {
              MigrationValidators::Core::DbValidator.add_column_validator "wrong_table", "column_name", "validator_name", :option_name => :option_value
              MigrationValidators::Core::DbValidator.commit
            }.should raise_error /table 'wrong_table' does not exist/
          end

          it "raises an error if column does not exists" do
            lambda {
              MigrationValidators::Core::DbValidator.add_column_validator "table_name", "wrong_column_name", "validator_name", :option_name => :option_value
              MigrationValidators::Core::DbValidator.commit
            }.should raise_error /column 'wrong_column_name' does not exist in the table 'table_name'/
          end
        end

        it "updates existing validator" do
          MigrationValidators::Core::DbValidator.add_column_validator "table_name", "column_name", "validator_name",  :option_name1 => :option_value1
          MigrationValidators::Core::DbValidator.commit


          MigrationValidators::Core::DbValidator.first.options[:option_name1].should == :option_value1
        end
      end

      describe :remove_column_validator do
        it "removes validatro with specified parameters" do
          MigrationValidators::Core::DbValidator.remove_column_validator "table_name", "column_name", "validator_name"
          MigrationValidators::Core::DbValidator.commit

          MigrationValidators::Core::DbValidator.count.should be_zero
        end
      end

      describe :remove_column_validators do
        it "removes all validators that are defined for the specified column"  do
          MigrationValidators::Core::DbValidator.add_column_validator "table_name", "column_name", "validator_name1",  :option_name => :option_value
          MigrationValidators::Core::DbValidator.commit

          MigrationValidators::Core::DbValidator.remove_column_validators "table_name", "column_name"
          MigrationValidators::Core::DbValidator.commit

          MigrationValidators::Core::DbValidator.count.should be_zero
        end
      end

      describe :rename_column do
        it "updates db validators" do
          MigrationValidators::Core::DbValidator.add_column_validator "table_name", "column_name", "validator_name1",  :option_name => :option_value
          MigrationValidators::Core::DbValidator.commit

          MigrationValidators::Core::DbValidator.rename_column "table_name", "column_name", "column_name_1"
          MigrationValidators::Core::DbValidator.commit

          MigrationValidators::Core::DbValidator.column_validators("table_name", "column_name_1").should_not be_blank
        end
      end

      describe :rename_table do
        it "updates db validators" do
          MigrationValidators::Core::DbValidator.rename_table "table_name", "new_table_name"
        end
      end

      describe :remove_table_validators do
        it "removes all validators that are defined for the specified table" do
          MigrationValidators::Core::DbValidator.remove_table_validators "table_name"
          MigrationValidators::Core::DbValidator.commit

          MigrationValidators::Core::DbValidator.count.should == 0
        end
      end
    end

    describe :satisfies do
      before :each do
        @validator = Factory.build(:db_validator, :options => {:property_name => :property_value})
      end

      it "returns false if the validator has different property values than specified"  do
        @validator.satisfies(:property_name => :property_value).should be_true
      end

      it "returns true if values of the specified property values are equals to validator's ones" do
        @validator = Factory.build(:db_validator, :options => {:property_name => :property_value})
      end

      it "returns false if at least one specified property is not defined in validator's options" do
        @validator = Factory.build(:db_validator, :options => {:property_name => :property_value})
      end

      it "returns true if empty was specified" do
        @validator = Factory.build(:db_validator, :options => {:property_name => :property_value})
      end

      it "allows arrays of possible values to be spesified" do
        @validator.satisfies(:property_name => [:property_value, :property_value1]).should be_true
        @validator.satisfies(:property_name1 => [:property_value, :property_value1]).should be_false
        @validator.satisfies(:property_name1 => [nil, :property_value1]).should be_true
      end
    end

    describe :table_validators do
      before :each do
        MigrationValidators::Core::DbValidator.add_column_validator "table_name", "column_name_1", "validator_name",  :option_name => :option_value_1
        MigrationValidators::Core::DbValidator.add_column_validator "table_name", "column_name_2", "validator_name",  :option_name => :option_value_2
        MigrationValidators::Core::DbValidator.add_column_validator "table_name", "column_name_3", "validator_name",  {}
        MigrationValidators::Core::DbValidator.commit
      end

      it "should return all validators that are defined for the specified table" do
        MigrationValidators::Core::DbValidator.table_validators("table_name").length.should == 4
      end

      it "allows to define options filter for the selected validators" do
        MigrationValidators::Core::DbValidator.table_validators("table_name", :option_name => :option_value_1).should == MigrationValidators::Core::DbValidator.column_validators(:table_name, :column_name_1)
      end

      it "allows to define nil in properties filter" do
        MigrationValidators::Core::DbValidator.table_validators("table_name", :option_name => [nil, :option_value_1]).should == MigrationValidators::Core::DbValidator.column_validators(:table_name, :column_name_1) + MigrationValidators::Core::DbValidator.column_validators(:table_name, :column_name_3)
      end
    end

    describe :column_validators do
      before :each do
        MigrationValidators::Core::DbValidator.add_column_validator "table_name", "column_name", "validator_name_1",  :option_name => :option_value_1
        MigrationValidators::Core::DbValidator.add_column_validator "table_name", "column_name", "validator_name_2",  :option_name => :option_value_2
        MigrationValidators::Core::DbValidator.add_column_validator "table_name", "column_name", "validator_name_3",  {}
        MigrationValidators::Core::DbValidator.commit
      end

      it "should return all validators that are defined for the specified column" do
        MigrationValidators::Core::DbValidator.column_validators("table_name", "column_name").length.should == 4
      end

      it "allows to define options filter for the selected validators" do
        column_validators = MigrationValidators::Core::DbValidator.column_validators("table_name", "column_name", :option_name => :option_value_1)

        column_validators.length.should == 1
        column_validators.first.validator_name.should == "validator_name_1"
      end

      it "allows to define nil in properties filter" do
        column_validators = MigrationValidators::Core::DbValidator.column_validators("table_name", "column_name", :option_name => [nil, :option_value_1])

        column_validators.length.should == 2
        column_validators.first.validator_name.should == "validator_name_1"
        column_validators.last.validator_name.should == "validator_name_3"
      end
    end

    describe :save_to_constraint do
      it "updates validator constraints list with string representation of the specified constraint name" do
        validator =  Factory.create :db_validator, :table_name => :table_name

        validator.save_to_constraint :constraint

        validator.constraints.should == ["constraint"]
      end

      it "does nothing if such constraint already exists in the list" do
        validator =  Factory.create :db_validator, :table_name => :table_name

        validator.save_to_constraint :constraint
        validator.save_to_constraint :constraint

        validator.constraints.should == ["constraint"]
      end
    end

    describe :remove_from_constraint do
      it "removes specified constraint name from the internal constraints list" do
        validator =  Factory.create :db_validator, :table_name => :table_name
        validator.constraints = ["constraint"]

        validator.remove_from_constraint :constraint

        validator.constraints.should be_blank
      end

      it "does nothing if validator was not added to the constraint with the specified name" do
        validator =  Factory.create :db_validator, :table_name => :table_name
        validator.constraints = nil

        validator.remove_from_constraint :constraint

        validator.constraints.should be_blank
      end
    end

    describe :in_constraint? do
      it "returns true if validator belongs to the constriant with specified name" do
        validator =  Factory.create :db_validator, :table_name => :table_name

        validator.save_to_constraint :constraint

        validator.in_constraint?(:constraint).should be_true
        validator.in_constraint?("constraint").should be_true
      end
    end

    describe :constraint_validators do
      it "searches validators that were included to constraint with specified name" do
        validator =  Factory.create :db_validator, :table_name => :table_name, :column_name => :column_name, :constraints => ["constraint"]
        validator1 =  Factory.create :db_validator, :table_name => :table_name, :column_name => :column_name_1, :constraints => ["constraint1"]

        MigrationValidators::Core::DbValidator.constraint_validators("constraint").to_a.should == [validator]
      end
    end
  end
end
