require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

Migration = ActiveRecord::Migration

class TestMigration < Migration, :type => :mv_test
  def self.up
    create_table :migration_test_table do |t|
      t.string :column_str, :validates => {:uniqueness => true}
      t.integer :column_int, :validates => {:uniqueness => true}
    end

    create_table :migration_test_table_1 do |t1| 
      t1.string :col
    end
  end

  def self.down
    validate_column :migration_test_table, :column_str, :uniqueness => false
    validate_column :migration_test_table, :column_int, :uniqueness => true
     
    drop_table :migration_test_table_1
  end
end

describe Migration, "migration validators extension" do
  before :all do
    ActiveRecord::Migration.verbose = false
    use_memory_db
  end

  before :each do
    TestAdapter.clear
    TestAdapter.stub_validate_method :uniqueness
    TestAdapter.stub_remove_validate_method :uniqueness

    MigrationValidators.adapter = TestAdapter.new
    DbValidator.rollback
    db.drop_table(:migration_test_table) if DB.table_exists?(:migration_test_table)
    db.drop_table(:migration_test_table_1) if DB.table_exists?(:migration_test_table_1)
    TestMigration.migrate :up
  end

  describe :migrate do
    describe :up do
      it "does ordinary :up migration" do
        db.table_exists?(:migration_test_table).should be_true
      end

      it "creates all defined validators" do
        DbValidator.column_validators(:migration_test_table, :column_str).should_not be_blank
      end

      it "call adapter validator creation methods" do
        TestAdapter.log[:validate_uniqueness].should_not be_blank
        TestAdapter.log[:remove_validate_uniqueness].should_not be_blank
      end
    end

    describe :down do
      before :each do
        TestMigration.migrate :down
      end

      it "does ordinary :down migration" do
        db.table_exists?(:migration_test_table_1).should be_false
      end

      it "creates all defined validators" do
        DbValidator.column_validators(:migration_test_table, :column_int).should_not be_blank
      end

      it "removes all removed validators" do
        DbValidator.column_validators(:migration_test_table, :column_str).should be_blank
      end

      it "call adapter validator creation methods" do
        TestAdapter.log[:validate_uniqueness].should_not be_blank
        TestAdapter.log[:remove_validate_uniqueness].should_not be_blank
      end
    end
  end
end
