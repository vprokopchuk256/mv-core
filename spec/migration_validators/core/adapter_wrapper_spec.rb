require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MigrationValidators::Core::AdapterWrapper, :type => :mv_test do
  before :each do
    use_memory_db
    db.initialize_schema_migrations_table
    MigrationValidators::Spec::Support::TestAdapter.clear
    @wrapper = MigrationValidators::Core::AdapterWrapper.new MigrationValidators::Spec::Support::TestAdapter.new
  end

  describe :create_validators do
    it "calls driver method if such validator is supported" do
      validator = Factory.build :uniqueness_check

      MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :uniqueness, :check
      @wrapper.create_validators [validator]

      MigrationValidators::Spec::Support::TestAdapter.log[:validate_uniqueness_check].should_not be_blank
      MigrationValidators::Spec::Support::TestAdapter.log[:validate_uniqueness_check].first.should == [validator]
    end

    it "groups validators by table_name, validator_name and db form" do
      validator1 = Factory.build :presense_check, :column_name => :column_name_1
      validator2 = Factory.build :presense_check, :column_name => :column_name_2

      MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :presense, :check
      @wrapper.create_validators [validator1, validator2]

      MigrationValidators::Spec::Support::TestAdapter.log[:validate_presense_check].first.should == [validator1, validator2]
    end

    it "calls driver method until all validatos are created if not all validators were handled" do
      validator1 = Factory.build :uniqueness_check, :column_name => :column_name_1
      validator2 = Factory.build :uniqueness_check, :column_name => :column_name_2

      MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :uniqueness, :check do |validators|
        [validators.first]
      end

      @wrapper.create_validators [validator1, validator2]

      MigrationValidators::Spec::Support::TestAdapter.log[:validate_uniqueness_check].first.should == [validator1, validator2]
      MigrationValidators::Spec::Support::TestAdapter.log[:validate_uniqueness_check].last.should == [validator2]
    end

    it "raises an exception is driver does not support specified validator" do
      MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :presense, :check

      validator = Factory.build :uniqueness_check

      lambda {
        @wrapper.create_validators [validator]
      }.should raise_error MigrationValidators::MigrationValidatorsException, /Action 'validate' for 'uniqueness' is not supported. Available validators: \['presense'\]/
    end

    it "raises an exception if driver does not support default db form for specified validator" do
      MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :presense, :check

      validator = Factory.build :presense

      lambda {
        @wrapper.create_validators [validator]
      }.should raise_error MigrationValidators::MigrationValidatorsException, /Action 'validate' for 'presense' with default db form is not supported/
    end

    it "raises an exception is driver does not support specified validator in specified db form" do
      MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :uniqueness, :trigger

      validator = Factory.build :uniqueness_check

      lambda {
        @wrapper.create_validators [validator]
      }.should raise_error MigrationValidators::MigrationValidatorsException, /Action 'validate' for db form 'check' for validator 'uniqueness' is not supported. Available db forms: \['trigger'\]/
    end

    it "handles omitted db form" do
      MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :uniqueness

      validator = Factory.build :uniqueness

      lambda {
        @wrapper.create_validators [validator]
      }.should_not raise_error


      MigrationValidators::Spec::Support::TestAdapter.log[:validate_uniqueness].first.should == [validator]
    end
  end

  describe :remove_validators do
    it "calls driver method if such validator remove is supported" do
      validator = Factory.build :uniqueness_check

      MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :uniqueness, :check
      @wrapper.remove_validators [validator]

      MigrationValidators::Spec::Support::TestAdapter.log[:remove_validate_uniqueness_check].should_not be_blank
      MigrationValidators::Spec::Support::TestAdapter.log[:remove_validate_uniqueness_check].first.should == [validator]
    end

    it "groups validators by table_name, validator_name and db form" do
      validator1 = Factory.build :presense_check, :column_name => :column_name_1
      validator2 = Factory.build :presense_check, :column_name => :column_name_2

      MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :presense, :check
      @wrapper.remove_validators [validator1, validator2]

      MigrationValidators::Spec::Support::TestAdapter.log[:remove_validate_presense_check].first.should == [validator1, validator2]
    end

    it "calls driver method until all validatos are removed if not all validators were handled" do
      validator1 = Factory.build :uniqueness_check, :column_name => :column_name_1
      validator2 = Factory.build :uniqueness_check, :column_name => :column_name_2

      MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :uniqueness, :check do |validators|
        [validators.first]
      end

      @wrapper.remove_validators [validator1, validator2]

      MigrationValidators::Spec::Support::TestAdapter.log[:remove_validate_uniqueness_check].first.should == [validator1, validator2]
      MigrationValidators::Spec::Support::TestAdapter.log[:remove_validate_uniqueness_check].last.should == [validator2]
    end

    it "raises an exception is driver does not support removing of the specified validator" do
      MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :presense, :check

      validator = Factory.build :uniqueness_check

      lambda {
        @wrapper.remove_validators [validator]
      }.should raise_error MigrationValidators::MigrationValidatorsException, /Action 'remove_validate' for 'uniqueness' is not supported. Available validators: \['presense'\]/
    end

    it "raises an exception if driver does not support removing validator with in default db form" do
      MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :presense, :check

      validator = Factory.build :presense

      lambda {
        @wrapper.remove_validators [validator]
      }.should raise_error MigrationValidators::MigrationValidatorsException, /Action 'remove_validate' for 'presense' with default db form is not supported/
    end

    it "raises an exception is driver does not support specified removing validator in specified db form" do
      MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :uniqueness, :trigger

      validator = Factory.build :uniqueness_check

      lambda {
        @wrapper.remove_validators [validator]
      }.should raise_error MigrationValidators::MigrationValidatorsException, /Action 'remove_validate' for db form 'check' for validator 'uniqueness' is not supported. Available db forms: \['trigger'\]/
    end

    it "handles omitted db form" do
      MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :uniqueness

      validator = Factory.build :uniqueness

      lambda {
        @wrapper.remove_validators [validator]
      }.should_not raise_error


      MigrationValidators::Spec::Support::TestAdapter.log[:remove_validate_uniqueness].first.should == [validator]
    end
  end
end
