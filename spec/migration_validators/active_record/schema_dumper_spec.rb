require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MigrationValidators::ActiveRecord::SchemaDumper, "migration validators extension", :type => :mv_test do
  subject(:validators) { MigrationValidators::Core::DbValidator.on_table(:test_table) }
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
 
  end

  its(:length) { is_expected.to eq(1) }

  context 'created validator' do
    subject{ validators.first }

    its(:validator_name) { is_expected.to eq('length') }
    its(:column_name) { is_expected.to eq('str_column') }
    its(:options) { is_expected.to eq({:in => [1..5], :message => :SomeErrorMessage})}
  end
end
