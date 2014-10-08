require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

Migration = ActiveRecord::Migration

describe Migration, :type => :mv_test do
  before :example do
    use_memory_db
  end

  before do
    db.initialize_migration_validators_table
    db.create_table :table_name do |t|
      t.string :column
    end
  end

  describe 'up/down version' do
    describe '#up' do
      let(:migration) do
        Class.new(Migration) do
          def up
            validate_column :table_name, :column, uniqueness: true
          end
        end
      end

      before do
      end

      subject{ migration.migrate :up }

      it { expect{ subject }.to change{ DbValidator.on_table(:table_name).on_column(:column).with_name(:uniqueness).count }.from(0).to(1)}
    end

    describe '#down' do
      let(:migration) do
        Class.new(Migration) do
          def down
            validate_column :table_name, :column, uniqueness: false
          end
        end
      end

      before do
        db.validate_column :table_name, :column, uniqueness: true
        DbValidator.commit
      end

      subject{ migration.migrate :down }

      it { expect{ subject }.to change{ DbValidator.on_table(:table_name).on_column(:column).with_name(:uniqueness).count }.from(1).to(0)}
    end
  end

  describe 'change version' do
    let(:migration) do
      Class.new(Migration) do
        def change
          validate_column :table_name, :column, uniqueness: true
        end
      end
    end

    describe '#up' do
      subject{ migration.migrate :up }

      it { expect{ subject }.to change{ DbValidator.on_table(:table_name).on_column(:column).with_name(:uniqueness).count }.from(0).to(1)}
    end

    #TODO: make it possible support code below
    # describe '#down' do
    #   before do
    #     migration.migrate :up
    #   end

    #   subject{ migration.migrate :down }

    #   it { expect{ subject }.to change{ DbValidator.on_table(:table_name).on_column(:column).with_name(:uniqueness).count }.from(1).to(0)}
    # end
  end
end
