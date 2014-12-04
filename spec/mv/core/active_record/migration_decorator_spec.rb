require 'spec_helper'

require 'mv/core/active_record/migration_decorator'
require 'mv/core/active_record/connection_adapters/table_definition_decorator'
require 'mv/core/active_record/connection_adapters/abstract_adapter_decorator'

describe Mv::Core::ActiveRecord::MigrationDecorator do
  before do
    ::ActiveRecord::Base.connection.class.send(
      :prepend, Mv::Core::ActiveRecord::ConnectionAdapters::AbstractAdapterDecorator
    )

    ::ActiveRecord::ConnectionAdapters::TableDefinition.send(
      :prepend, Mv::Core::ActiveRecord::ConnectionAdapters::TableDefinitionDecorator
    )

    ::ActiveRecord::Migration.send(
      :prepend, Mv::Core::ActiveRecord::MigrationDecorator
    )

    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    # Mv::Core::Migration::Base.set_current('20141118164617')
  end

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

    it "sets current migration" do
      expect(Mv::Core::Migration::Base).to receive(:set_current).with('20141118164617').and_call_original
      migrate_up
    end

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

    it "sets current migration" do
      expect(Mv::Core::Migration::Base).to receive(:set_current).with('20141118164617').and_call_original
      migrate_down
    end

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