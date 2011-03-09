require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MigrationValidators::ActiveRecord::SchemaDumper, "migration validators extension", :type => :mv_test do
  before :all do
    ActiveRecord::Migration.verbose = false
    use_memory_db
    db.initialize_schema_migrations_table
  end

  before :each do
    MigrationValidators::Core::DbValidator.clear_all
    db.drop_table :test_table if db.table_exists?(:test_table)

    db.create_table :test_table do |t| 
      t.string :str_column, :validates => {:length => {:in => [1..5], :message => :SomeErrorMessage} }
    end

    MigrationValidators::Core::DbValidator.commit


    schema = StringIO.new
    ::ActiveRecord::SchemaDumper.dump(db, schema)

    MigrationValidators::Core::DbValidator.clear_all
    
    db.drop_table :test_table

    db.instance_eval(schema.string)

    MigrationValidators::Core::DbValidator.commit
 
    @validators = MigrationValidators::Core::DbValidator.table_validators "test_table"
  end

  describe :dump do
    it "validator info" do
      @validators.length.should == 1
      @validators.first.validator_name.should == "length"
      @validators.first.column_name.should == "str_column"
      @validators.first.options.should == {:in => [1..5], :message => :SomeErrorMessage}
    end
  end

end
