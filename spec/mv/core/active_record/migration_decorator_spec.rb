require 'spec_helper'

describe Mv::Core::ActiveRecord::MigrationDecorator do
  before do
    ::ActiveRecord::Base.connection.class.send(
      :prepend, Mv::Core::ActiveRecord::ConnectionAdapters::AbstractAdapterDecorator
    )

    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
  end

  describe "change" do
    # describe 'validates in change_table' do
    #   before :each do
    #     ::ActiveRecord::Base.connection.create_table :table_name, id: false do |t|
    #       t.string :column_name #
    #     end
    #   end

    #   let(:migration) do
    #     Class.new(::ActiveRecord::Migration) do
    #       def change
    #         change_table :table_name do |t|
    #           t.validates :column_name, length: { is: 4 }
    #         end
    #       end
    #     end.new('TestMigration', '20141118164617')
    #   end

    #   describe "#up" do
    #     subject(:migrate_up) { migration.migrate(:up) }

    #     it "should call add_column on migration presenter" do
    #       expect(Mv::Core::Migration::Base).to receive(:change_column).with(
    #         "table_name", :column_name, length: { is: 4 }
    #       )
    #       migrate_up
    #     end

    #     it "should call execute on migration presenter" do
    #       expect(Mv::Core::Migration::Base).to receive(:execute)
    #       migrate_up
    #     end
    #   end

    #   describe "#down" do
    #     subject(:migrate_down) { migration.migrate(:down) }

    #     it "it should raise migration irreversible exception" do
    #       expect { migrate_down }.to raise_error(::ActiveRecord::IrreversibleMigration)
    #     end
    #   end
    # end
    
    describe 'validates standalone' do
      before :each do
        ::ActiveRecord::Base.connection.create_table :table_name, id: false do |t|
          t.string :column_name #
        end
      end

      let(:migration) do
        Class.new(::ActiveRecord::Migration) do
          def change
            validates :table_name, :column_name, length: { is: 4 }
          end
        end.new('TestMigration', '20141118164617')
      end

      describe "#up" do
        subject(:migrate_up) { migration.migrate(:up) }

        it "should call add_column on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:change_column).with(
            "table_name", :column_name, length: { is: 4 }
          )
          migrate_up
        end

        it "should call execute on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:execute)
          migrate_up
        end
      end

      describe "#down" do
        subject(:migrate_down) { migration.migrate(:down) }

        it "it should raise migration irreversible exception" do
          expect { migrate_down }.to raise_error(::ActiveRecord::IrreversibleMigration)
        end
      end
    end

    describe 'change_column' do
      before :each do
        ::ActiveRecord::Base.connection.create_table :table_name, id: false do |t|
          t.string :column_name, validates: { length: { is: 4 } }
        end
      end

      let(:migration) do
        Class.new(::ActiveRecord::Migration) do
          def change
            change_table :table_name, id: false do |t|
              t.change :column_name, :string, validates: { length: { is: 5 } }
            end
          end
        end.new('TestMigration', '20141118164617')
      end

      describe "#up" do
        subject(:migrate_up) { migration.migrate(:up) }

        it "should call add_column on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:change_column).with(
            "table_name", :column_name, length: { is: 5 }
          )
          migrate_up
        end

        it "should call execute on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:execute)
          migrate_up
        end
      end

      describe "#down" do
        subject(:migrate_down) { migration.migrate(:down) }

        it "change column should stay irreversible" do
          expect { migrate_down }.to raise_error(::ActiveRecord::IrreversibleMigration)
        end
      end
    end

    describe 'drop_table' do
      before :each do
        ::ActiveRecord::Base.connection.create_table :table_name, id: false do |t|
          t.string :column_name, validates: { length: { is: 4 } }
        end
      end

      let(:migration) do
        Class.new(::ActiveRecord::Migration) do
          def change
            drop_table :table_name
          end
        end.new('TestMigration', '20141118164617')
      end

      describe "#up" do
        subject(:migrate_up) { migration.migrate(:up) }

        it "calls original migration call" do
          migrate_up
          expect(::ActiveRecord::Base.connection.table_exists?(:table_name)).to be_falsey
        end

        it "should call add_column on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:drop_table).with("table_name")
          migrate_up
        end

        it "should call execute on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:execute)
          migrate_up
        end
      end

      describe "#down" do
        subject(:migrate_down) { migration.migrate(:down) }

        it "should call add_column on migration presenter" do
          expect { migrate_down }.to raise_error(::ActiveRecord::IrreversibleMigration)
        end
      end
    end

    describe 'remove_column' do
      before :each do
        ::ActiveRecord::Base.connection.create_table :table_name, id: false do |t|
          t.string :column_name, validates: { length: { is: 4 } }
          t.string :column_name_1
        end
      end

      let(:migration) do
        Class.new(::ActiveRecord::Migration) do
          def change
            change_table :table_name do |t|
              t.remove :column_name
            end
          end
        end.new('TestMigration', '20141118164617')
      end

      describe "#up" do
        subject(:migrate_up) { migration.migrate(:up) }

        it "calls original migration call" do
          migrate_up
          expect(::ActiveRecord::Base.connection.column_exists?(:table_name, :column_name)).to be_falsey
        end

        it "should call add_column on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:remove_column).with("table_name", :column_name)
          migrate_up
        end

        it "should call execute on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:execute)
          migrate_up
        end
      end

      describe "#down" do
        subject(:migrate_down) { migration.migrate(:down) }

        it "should call add_column on migration presenter" do
          expect { migrate_down }.to raise_error(::ActiveRecord::IrreversibleMigration)
        end
      end
    end

    describe 'rename_table' do
      before :each do
        ::ActiveRecord::Base.connection.create_table :table_name, id: false do |t|
          t.string :column_name, validates: { length: { is: 4 } }
        end
      end

      let(:migration) do
        Class.new(::ActiveRecord::Migration) do
          def change
            rename_table :table_name, :table_name_1
          end
        end.new('TestMigration', '20141118164617')
      end

      describe "#up" do
        subject(:migrate_up) { migration.migrate(:up) }

        it "calls original migration call" do
          migrate_up
          expect(::ActiveRecord::Base.connection.table_exists?(:table_name)).to be_falsey
        end

        it "should call add_column on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:rename_table).with("table_name", "table_name_1")
          migrate_up
        end

        it "should call execute on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:execute)
          migrate_up
        end
      end

      describe "#down" do
        before { migration.migrate(:up) }
        subject(:migrate_down) { migration.migrate(:down) }

        it "calls original migration call" do
          migrate_down
          expect(::ActiveRecord::Base.connection.table_exists?(:table_name_1)).to be_falsey
        end

        it "should call add_column on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:rename_table).with("table_name_1", "table_name")
          migrate_down
        end

        it "should call execute on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:execute)
          migrate_down
        end
      end
    end

    describe 'add column' do
      let(:migration) do
        Class.new(::ActiveRecord::Migration) do
          def change
            create_table :table_name, id: false do |t|
              t.string :column_name, validates: { length: { is: 5 } }
            end
          end
        end.new('TestMigration', '20141118164617')
      end
      
      describe "#up" do
        subject(:migrate_up) { migration.migrate(:up) }

        it "calls original migration call" do
          migrate_up
          expect(::ActiveRecord::Base.connection.table_exists?(:table_name)).to be_truthy
        end

        it "should call add_column on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:add_column).with(
            "table_name", :column_name, length: { is: 5 }
          )
          migrate_up
        end

        it "should call execute on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:execute)
          migrate_up
        end
      end

      describe "#down" do
        before { migration.migrate(:up) }

        subject(:migrate_down) { migration.migrate(:down) }

        it "calls original migration call" do
          migrate_down
          expect(::ActiveRecord::Base.connection.table_exists?(:table_name)).to be_falsey
        end

        it "should call add_column on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:drop_table).with("table_name")
          migrate_down
        end

        it "should call execute on migration presenter" do
          expect(Mv::Core::Migration::Base).to receive(:execute)
          migrate_down
        end
      end
    end
  end
  
  describe "up & down" do
    let(:migration) do
      Class.new(::ActiveRecord::Migration) do
        def up
          create_table :table_name, id: false do |t|
            t.string :column_name, validates: { length: { is: 5 } }
          end
        end

        def down
          drop_table :table_name
        end
      end.new('TestMigration', '20141118164617')
    end

    describe "#up" do
      subject(:migrate_up) { migration.migrate(:up) }

      it "calls original migration call" do
        migrate_up
        expect(::ActiveRecord::Base.connection.table_exists?(:table_name)).to be_truthy
      end

      it "should call add_column on migration presenter" do
        expect(Mv::Core::Migration::Base).to receive(:add_column).with(
          "table_name", :column_name, length: { is: 5 }
        )
        migrate_up
      end

      it "should call execute on migration presenter" do
        expect(Mv::Core::Migration::Base).to receive(:execute)
        migrate_up
      end
    end

    describe "#down" do
      before { migration.migrate(:up) }

      subject(:migrate_down) { migration.migrate(:down) }

      it "calls original migration call" do
        migrate_down
        expect(::ActiveRecord::Base.connection.table_exists?(:table_name)).to be_falsey
      end

      it "should call add_column on migration presenter" do
        expect(Mv::Core::Migration::Base).to receive(:drop_table).with("table_name")
        migrate_down
      end

      it "should call execute on migration presenter" do
        expect(Mv::Core::Migration::Base).to receive(:execute)
        migrate_down
      end
    end
  end
end