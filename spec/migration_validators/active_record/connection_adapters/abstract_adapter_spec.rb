require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

AbstractAdapter = ::ActiveRecord::ConnectionAdapters::AbstractAdapter

describe ::ActiveRecord::ConnectionAdapters::AbstractAdapter, "migration validators extension", :type => :mv_test do

  before :all do
    use_memory_db
    @migrations_table = ::ActiveRecord::Migrator::schema_migrations_table_name
    @validators_table = MigrationValidators.migration_validators_table_name
  end

  before :each do
    MigrationValidators::Core::DbValidator.rollback
  end

  describe :initialize_migration_validators_table do
    before :each do
      db.drop_table @validators_table if db.table_exists?(@validators_table)
    end

    it "creates table if it's not created" do
      db.initialize_migration_validators_table
      db.table_exists?(@validators_table).should be_true
    end

    it "should not throw an error if table already exists" do
      db.initialize_migration_validators_table

      lambda { db.initialize_migration_validators_table }.should_not raise_error
    end
  end

  describe :initialize_schema_migrations_table do
    before :each do

      db.do_internally do
        db.drop_table @migrations_table if db.table_exists?(@migrations_table)
        db.drop_table @validators_table if db.table_exists?(@validators_table)
      end
      db.initialize_schema_migrations_table
    end

    it "should initialize migrations table as usuall" do
      db.table_exists?(@migrations_table).should be_true
    end

    it "should also initialize validators table" do
      db.table_exists?(@validators_table).should be_true
    end
  end

  describe "synchronization with schema statements" do
    before :each do

      db.do_internally do
        db.drop_table :new_table_name if db.table_exists?(:new_table_name)
        db.drop_table :table_name if db.table_exists?(:table_name)
        db.create_table(:table_name) do |t|
          t.string :column_name 
          t.string :column_name1
        end 
      end

      MigrationValidators::Core::DbValidator.delete_all
    end

    describe :drop_table do
      it "drops all validators of the dropped table" do
        db.validate_column :table_name, :column_name, :uniqueness => {:message => "some message"}
        MigrationValidators::Core::DbValidator.commit

        db.drop_table :table_name
        MigrationValidators::Core::DbValidator.commit

        MigrationValidators::Core::DbValidator.count.should be_zero
      end

      it "still drops table" do
        db.drop_table :table_name
        db.table_exists?(:table_name).should be_false
      end
    end

    describe :remove_column do
      it "removes column validators" do
        db.validate_column :table_name, :column_name, :uniqueness => {:message => "some message"}
        db.validate_column :table_name, :column_name1, :uniqueness => {:message => "some message"}
        MigrationValidators::Core::DbValidator.commit

        db.remove_column :table_name, :column_name1
        MigrationValidators::Core::DbValidator.commit

        MigrationValidators::Core::DbValidator.count.should == 1
        MigrationValidators::Core::DbValidator.first.column_name.should == "column_name"
      end

      it "still removes column" do
        db.remove_column :table_name, :column_name1
        db.column_exists?(:table_name, :column_name1).should be_false
      end
    end


    describe :rename_column do
      it "updates column name in validators table" do
        db.validate_column :table_name, :column_name, :uniqueness => {:message => "some message"}
        db.validate_column :table_name, :column_name1, :uniqueness => {:message => "some message"}
        MigrationValidators::Core::DbValidator.commit

        db.rename_column :table_name, :column_name1, :column_name2
        MigrationValidators::Core::DbValidator.commit

        MigrationValidators::Core::DbValidator.column_validators(:table_name, :column_name2).should_not be_blank
      end

      it "still renames column" do
        db.rename_column :table_name, :column_name1, :column_name2
        MigrationValidators::Core::DbValidator.commit

        db.column_exists?(:table_name, :column_name1).should be_false
        db.column_exists?(:table_name, :column_name2).should be_true
      end
    end

    describe :rename_table do
      it "updates table name in validators table" do
        db.validate_column :table_name, :column_name, :uniqueness => {:message => "some message"}
        MigrationValidators::Core::DbValidator.commit

        db.rename_table :table_name, :new_table_name
        MigrationValidators::Core::DbValidator.commit

        MigrationValidators::Core::DbValidator.table_validators(:new_table_name).should_not be_blank
      end

      it "still renames table" do
        db.rename_table :table_name, :new_table_name

        db.table_exists?(:table_name).should be_false
        db.table_exists?(:new_table_name).should be_true
      end
    end

    describe :add_column do
      before :each do
        db.add_column :table_name, :new_column, :integer, :validates => {:uniqueness => true}
        MigrationValidators::Core::DbValidator.commit
      end

      it "should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:table_name, :new_column).should_not be_blank
      end

      it "should still add column" do
        db.column_exists?(:table_name, :new_column).should be_true
      end
    end

    describe :change_column do
      before :each do
        db.add_column :table_name, :new_column, :integer, :validates => {:uniqueness => true}
        MigrationValidators::Core::DbValidator.commit

        db.change_column :table_name, :new_column, :string, :validates => {:presense => true}
        MigrationValidators::Core::DbValidator.commit
      end

      it "should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:table_name, :new_column).first.validator_name.should == "presense"
      end

      it "should still change column" do
        db.columns(:table_name).find{|col| col.name.to_sym == :new_column}.type.should == :string
      end
    end

    describe :create_table do
      before :each do
        db.drop_table :created_table if db.table_exists?(:created_table)
        db.create_table :created_table do |t|
          t.column :column, :string, :validates => {:presense => true} 
          t.string :string_column, :validates => {:presense => true} 
          t.text :text_column, :validates => {:presense => true} 
          t.integer :integer_column, :validates => {:presense => true} 
          t.float :float_column, :validates => {:presense => true} 
          t.decimal :decimal_column, :validates => {:presense => true} 
          t.datetime :datetime_column, :validates => {:presense => true} 
          t.time :time_column, :validates => {:presense => true} 
          t.date :date_column, :validates => {:presense => true} 
          t.binary :binary_column, :validates => {:presense => true} 
          t.boolean :boolean_column, :validates => {:presense => true} 
        end

        MigrationValidators::Core::DbValidator.commit
      end

      it "with generall column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :column).should_not be_blank
      end

      it "with string column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :string_column).should_not be_blank
      end

      it "with text column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :text_column).should_not be_blank
      end

      it "with integer column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :integer_column).should_not be_blank
      end

      it "with float column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :float_column).should_not be_blank
      end

      it "with decimal column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :decimal_column).should_not be_blank
      end

      it "with datetime column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :datetime_column).should_not be_blank
      end

      it "with time column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :time_column).should_not be_blank
      end

      it "with date column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :date_column).should_not be_blank
      end

      it "with binary column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :binary_column).should_not be_blank
      end

      it "with boolean column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :boolean_column).should_not be_blank
      end
    end
  end

  describe :change_table do
    describe "create_columns" do
      before :each do
        db.drop_table :created_table if db.table_exists?(:created_table)
        db.create_table(:created_table) {|t| t.string :dummy_column }
        db.change_table :created_table do |t|
          t.column :column, :string, :validates => {:presense => true} 
          t.string :string_column, :validates => {:presense => true} 
          t.text :text_column, :validates => {:presense => true} 
          t.integer :integer_column, :validates => {:presense => true} 
          t.float :float_column, :validates => {:presense => true} 
          t.decimal :decimal_column, :validates => {:presense => true} 
          t.datetime :datetime_column, :validates => {:presense => true} 
          t.time :time_column, :validates => {:presense => true} 
          t.date :date_column, :validates => {:presense => true} 
          t.binary :binary_column, :validates => {:presense => true} 
          t.boolean :boolean_column, :validates => {:presense => true} 
        end

        MigrationValidators::Core::DbValidator.commit
      end

      it "with generall column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :column).should_not be_blank
      end

      it "with string column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :string_column).should_not be_blank
      end

      it "with text column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :text_column).should_not be_blank
      end

      it "with integer column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :integer_column).should_not be_blank
      end

      it "with float column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :float_column).should_not be_blank
      end

      it "with decimal column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :decimal_column).should_not be_blank
      end

      it "with datetime column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :datetime_column).should_not be_blank
      end

      it "with time column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :time_column).should_not be_blank
      end

      it "with date column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :date_column).should_not be_blank
      end

      it "with binary column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :binary_column).should_not be_blank
      end

      it "with boolean column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :boolean_column).should_not be_blank
      end
    end

    describe "change_existing_columns" do
      before :each do
        db.drop_table :created_table if db.table_exists?(:created_table)

        db.create_table :created_table do |t|
          t.column :column, :string, :validates => {:presense => true} 
          t.column :column_1, :string, :validates => {:presense => true} 
          t.column :column_to_remove, :string, :validates => {:presense => true}
          t.column :old_column_name, :string, :validates => {:presense => true}
        end

        MigrationValidators::Core::DbValidator.commit


        db.change_table :created_table do |t|
          t.change :column, :string, :validates => {:presense => false} 
          t.remove :column_to_remove
          t.rename :old_column_name, :new_column_name
          t.change_validates :column_1, :presense => false
        end

        MigrationValidators::Core::DbValidator.commit
      end

      it "with generall column should update validators table" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :column).should be_blank
      end

      it "should track column removing" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :column_to_remove).should be_blank
      end

      it "should trach column renaming" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :old_column_name).should be_blank
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :new_column_name).should_not be_blank
      end

      it "supports special change_validates method" do
        MigrationValidators::Core::DbValidator.column_validators(:created_table, :column_1).should be_blank
      end
    end
  end


  describe "operations with validators" do
    before :each do
      db.create_table(:table_name) do |t|
        t.string :column_name 
      end unless db.table_exists?(:table_name)
      
      MigrationValidators::Core::DbValidator.remove_table_validators :table_name
      MigrationValidators::Core::DbValidator.commit
    end

    describe :validate_column do
      it "raises an exception if 0 validators defined" do
        lambda {
          db.validate_column :table_name, :column_name, {}
        }.should raise_error(MigrationValidators::MigrationValidatorsException, /at least one column validator should be defined/)
      end

      it "adds all specified validators to the validator table" do

        db.validate_column :table_name, 
                           :column_name, 
                           :uniqueness => {:message => "unique"}, 
                           :inclusion => {:message => "inclusion"}
        MigrationValidators::Core::DbValidator.commit

        MigrationValidators::Core::DbValidator.column_validators("table_name", "column_name").length.should == 2
      end

      it "stores validator options if they defined as hash" do
        db.validate_column :table_name, 
                           :column_name, 
                           :uniqueness => {:message => "unique"}
        MigrationValidators::Core::DbValidator.commit


        MigrationValidators::Core::DbValidator.table_validators("table_name").first.options[:message].should == "unique"
      end

      it "should treat true in validator options as empty options list" do
        db.validate_column :table_name, 
                           :column_name, 
                           :uniqueness => true
        MigrationValidators::Core::DbValidator.commit

        MigrationValidators::Core::DbValidator.table_validators("table_name").first.options.should == {}
      end

      it "should treat false in validator option as validator removing request" do
        db.validate_column :table_name, 
                           :column_name, 
                           :uniqueness => true
        MigrationValidators::Core::DbValidator.commit

        db.validate_column :table_name, 
                           :column_name, 
                           :uniqueness => false
        MigrationValidators::Core::DbValidator.commit

        MigrationValidators::Core::DbValidator.table_validators(:table_name).should be_blank
      end

      it "should not allow nil instead of false as validator parameter" do
        lambda {
          db.validate_column :table_name, 
                             :column_name, 
                             :uniqueness => nil
          MigrationValidators::Core::DbValidator.commit
        }.should raise_error(MigrationValidators::MigrationValidatorsException, /use false to remove column validator/)
      end

      it "takes name of the context table if blank table name specified as parameter" do
        db.in_context_of_table :table_name do
          db.validate_column nil, 
                             :column_name, 
                             :uniqueness => true 
          MigrationValidators::Core::DbValidator.commit
        end

        MigrationValidators::Core::DbValidator.column_validators("table_name", "column_name").length.should == 1
      end
    end

    describe :validate_table, "supports" do
    end
  end
end
