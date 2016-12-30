require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'

describe Mv::Core::ActiveRecord::BaseDecorator do
  def db
    ::ActiveRecord::Base.connection
  end

  before do
    db.drop_table(:table_name) if db.data_source_exists?(:table_name)
    db.create_table :table_name do |t|
      t.column :column_name, column_type
    end

  end

  let(:klass) {
    Object.send(:remove_const, :TestBaseDecoratorClass) if defined?(TestBaseDecoratorClass)

    TestBaseDecoratorClass = Class.new(::ActiveRecord::Base) do
      self.table_name = 'table_name'

      enforce_migration_validations
    end
  }

  subject { klass.new(column_name: :column_value) }

  let(:column_type) { :string }

  context 'when migration validators table is not initialized' do
    it 'does not raise an error' do
      expect { subject.valid? }.not_to raise_error
    end
  end

  context 'when migration validators table properly initialized' do
    before do
      Mv::Core::Services::CreateMigrationValidatorsTable.new.execute

      create(:migration_validator,
             table_name: :table_name,
             column_name: :column_name,
             validation_type: validation_type,
             options: opts)
    end

    describe "when custom validation defined" do
      let(:validation_type) { :custom }
      let(:opts) { { statement: '{column_name} IS NOT NULL'} }

      it { is_expected.not_to validate_presence_of(:column_name) }
    end

    describe "when presence validation defined" do
      let(:validation_type) { :presence }
      let(:opts) { {} }

      it { is_expected.to validate_presence_of(:column_name) }
    end

    describe "when uniqueness validation defined" do
      let(:validation_type) { :uniqueness }
      let(:opts) { {} }

      it { is_expected.to validate_uniqueness_of(:column_name) }
    end

    describe "when absence validation defined" do
      let(:validation_type) { :absence }
      let(:opts) { {} }

      it { is_expected.to validate_absence_of(:column_name) }
    end

    describe "when inclusion validation defined" do
      let(:validation_type) { :inclusion }

      describe "array" do
        let(:opts) { { in: ['str1', 'str2'] } }

        it { is_expected.to validate_inclusion_of(:column_name).in_array(['str1', 'str2']) }
      end

      describe "range" do
        let(:column_type) { :integer }
        let(:opts) { { in: 1..3 } }

        it { is_expected.to validate_inclusion_of(:column_name).in_range(1..3) }
      end
    end

    describe "when exclusion validation defined" do
      let(:validation_type) { :exclusion }

      describe "array" do
        let(:opts) { { in: ['str1', 'str2'] } }

        it { is_expected.to validate_exclusion_of(:column_name).in_array(['str1', 'str2']) }
      end

      describe "range" do
        let(:column_type) { :integer }
        let(:opts) { { in: 1..3 } }

        it { is_expected.to validate_exclusion_of(:column_name).in_range(1..3) }
      end
    end

    describe "when length validation defined" do
      let(:validation_type) { :length }

      describe ":in" do
        let(:opts) { { in: 1..3 } }

        it { is_expected.to validate_length_of(:column_name) }
      end

      describe ":is" do
        let(:opts) { { is: 1 } }

        it { is_expected.to validate_length_of(:column_name).is_equal_to(1) }
      end

      describe ":within" do
        let(:opts) { { within: 1..3 } }

        it { is_expected.to validate_length_of(:column_name) }
      end

      describe ":minimum" do
        let(:opts) { { minimum: 1 } }

        it { is_expected.to validate_length_of(:column_name).is_at_least(1) }
      end

      describe ":maximum" do
        let(:opts) { { maximum: 1 } }

        it { is_expected.to validate_length_of(:column_name).is_at_most(1) }
      end
    end
  end

end
