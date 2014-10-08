require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')


describe MigrationValidators::Core::DbValidator, :type => :mv_test do
  before :example do
    use_memory_db
    db.initialize_schema_migrations_table
  end

  before :each do 
    db.create_table(:table_name) do |t|
      t.string :column_name
    end
    described_class.clear_all
  end

  after :each do
    db.drop_table(:table_name)
  end

  subject(:validator){ 
    described_class.new(table_name: :table_name, 
                        column_name: :column_name, 
                        validator_name: :validator_name) 
  }

  context 'initialization' do
    its(:options) { is_expected.to eq({})}
    its(:constraints) { is_expected.to be_kind_of(MigrationValidators::Core::ValidatorConstraintsList) }
  end

  context 'validators' do
    it { is_expected.to be_valid }

    it { should validate_presence_of(:table_name) }
    it { should ensure_length_of(:table_name).is_at_most(255) }
    it { is_expected.not_to allow_value(:table_name_1).for(:table_name).with_message("table 'table_name_1' does not exist") }
    
    it { should ensure_length_of(:column_name).is_at_most(255) }
    it { is_expected.not_to allow_value(:column_name_1).for(:column_name).with_message("column 'column_name_1' does not exist in the table 'table_name'") }

    it { should validate_presence_of(:validator_name) }
    it { should ensure_length_of(:validator_name).is_at_most(255) }
  end

  context 'db' do
    it { should have_db_column(:table_name).of_type(:string).with_options(:length => 255, :null => false) }
    it { should have_db_index(:table_name)}

    it { should have_db_column(:column_name).of_type(:string).with_options(:length => 255, :null => true) }
    it { should have_db_column(:options).of_type(:text)}
    it { should have_db_column(:constraints).of_type(:text)}
    
    it { should have_db_column(:validator_name).of_type(:string).with_options(:length => 255, :null => false) }
  end

  describe '#name' do
    subject { validator.name }

    it { is_expected.to eq('table_name_column_name_validator_name') }
  end

  describe '#error_message' do
    subject { validator.error_message }

    context 'by default' do
      it { is_expected.to eq('validator_name violated for table_name field column_name') }
    end

    context 'when defined in properties' do
      before { validator.options[:message] = 'custom error message' }
      
      it { is_expected.to eq('custom error message')}
    end
  end

  describe '#satisfies' do
    before { validator.options[:option] = :value }
    
    subject { validator.satisfies(opts) }

    context 'when options are empty' do
      let(:opts) { {} }

      it { is_expected.to be_truthy }
    end

    context 'when option and value are the same' do
      let(:opts) { validator.options }

      it { is_expected.to be_truthy }
    end

    context 'when value is in array' do
      let(:opts) { {option: [:value]} }

      it { is_expected.to be_truthy }
    end

    context 'when value is invalid' do
      let(:opts) { {option: [:value1]} }

      it { is_expected.to be_falsey }
    end
  end

  describe '#self.satisfies' do
    before do 
      validator.options[:option] = :value 
      validator.save!
    end
    
    subject { described_class.satisfies(opts) }

    context 'when valid' do
      let(:opts) { {option: [:value]} }

      it { is_expected.to eq([validator]) }
    end

    context 'when invalid' do
      let(:opts) { {option: [:value1]} }

      it { is_expected.to be_empty }
    end
  end

  describe 'constraints serialization' do
    before do 
      validator.constraints.add(:constraint) 
      validator.save!
    end

    subject{ validator.reload.constraints }

    its(:raw_list) { is_expected.to eq(['constraint']) }
  end

  describe '#delayed_destroy' do
    before { validator.save! }
    subject(:delayed_destroy) { validator.delayed_destroy }

    it { expect{ subject }.not_to change(described_class, :count) }

    context 'when commited' do
      subject do 
        delayed_destroy
        described_class.commit 
      end

      it { expect{ subject }.to change(described_class, :count).by(-1) }
    end
  end

  describe '#self.delayed_destroy' do
    before { validator.save! }

    subject(:delayed_destroy) { described_class.delayed_destroy }

    it { expect{ subject }.not_to change(described_class, :count) }

    context 'when commited' do
      subject do 
        delayed_destroy
        described_class.commit
      end

      it { expect{ subject }.to change(described_class, :count).by(-1) }
    end
  end

  describe '#delayed_save' do
    subject(:delayed_save) { validator.delayed_save }

    it { expect{ subject }.not_to change(described_class, :count) }

    context 'when commited' do
      subject(:commit) do
        delayed_save
        described_class.commit 
      end
      
      context 'when similiar validators does not exist' do
        it { expect{ subject }.to change(described_class, :count).by(1) }
      end

      context 'when similiar validator exist' do
        before do 
          described_class.create!(
            table_name: :table_name, 
            column_name: :column_name, 
            validator_name: :validator_name, 
            options: { option_name: :old_option_value }
            ) 
          validator.options[:option_name] = :new_option_value
        end

        it do
          expect{ subject }.to change {
            described_class.first.options[:option_name] 
          }.from(:old_option_value).to(:new_option_value)
        end
      end
    end
  end

  describe '#delayed_save' do
    subject(:delayed_save) { validator.delayed_save }

    it { expect{ subject }.not_to change(described_class, :count) }

    context 'when commited' do
      subject(:commit) do
        delayed_save
        described_class.commit 
      end
      
      context 'when similiar validators does not exist' do

        it { expect{ subject }.to change(described_class, :count).by(1) }
      end

      context 'when validator exist' do
        before do 
          described_class.create!(
            table_name: :table_name, 
            column_name: :column_name, 
            validator_name: :validator_name, 
            options: { option_name: :old_option_value }
            ) 
          validator.options[:option_name] = :new_option_value
        end

        context 'with the same attributes' do
          it do
            expect{ subject }.to change {
              described_class.first.options[:option_name] 
            }#.from(:old_option_value).to(:new_option_value)
          end

          it { expect{ subject }.not_to change(described_class, :count) }
        end

        context 'with different validator_name' do
          before { validator.validator_name = :other_validator_name }

          it { expect{ subject }.to change(described_class, :count).by(1) }
        end
      end
    end
  end

  describe '#on_table' do
    before { validator.save! }

    context 'when valid' do
      subject { described_class.on_table(:table_name) }

      it { is_expected.to eq([validator])}
    end

    context 'when invalid' do
      subject { described_class.on_table(:invalid_table_name) }

      it { is_expected.to be_empty }
    end
  end

  describe '#on_column' do
    before { validator.save! }

    context 'when valid' do
      subject { described_class.on_column(:column_name) }

      it { is_expected.to eq([validator])}
    end

    context 'when invalid' do
      subject { described_class.on_column(:invalid_column_name) }

      it { is_expected.to be_empty }
    end
  end

  describe '#with_name' do
    before { validator.save! }

    context 'when valid' do
      subject { described_class.with_name(:validator_name) }

      it { is_expected.to eq([validator])}
    end

    context 'when invalid' do
      subject { described_class.with_name(:invalid_validator_name) }

      it { is_expected.to be_empty }
    end
  end

  describe '#self.constraint_validators' do
    subject{ described_class.constraint_validators(:constraint_name) }

    context 'when validator with the specified constraint exists' do
      before do 
        validator.constraints.add(:constraint_name) 
        validator.save!
      end

      it { is_expected.to eq([validator]) }
    end

    context 'when validator with the specified constraint does not exist' do
      before do 
        validator.constraints.add(:invalid_constraint_name) 
        validator.save!
      end

      it { is_expected.to be_empty }
    end

    context 'when validator is new and not commmitted' do
      before do 
        validator.constraints.add(:constraint_name) 
        validator.delayed_save
      end

      it { is_expected.to eq([validator]) }
    end

    context 'when validator is to be deleted and that not committed yet' do
      before do 
        validator.constraints.add(:constraint_name) 
        validator.save!
        validator.delayed_destroy
      end

      it { is_expected.to be_empty }
    end
  end

  describe '#rename_table' do
    before { validator.save! }

    context 'existing' do
      subject{ described_class.rename_table(:table_name, :new_table_name) }

      it { expect{subject}.to change{validator.reload.table_name}.from('table_name').to('new_table_name') }
    end

    context 'not existing' do
      subject{ described_class.rename_table(:invalid_table_name, :new_table_name) }
      
      it { expect{subject}.not_to change{validator.reload.table_name} }
    end
  end

  describe '#rename_table' do
    before { validator.save! }


    context 'existing table and column' do
      subject{ described_class.rename_column(:table_name, :column_name, :new_column_name) }

      it { expect{subject}.to change{validator.reload.column_name}.from('column_name').to('new_column_name') }
    end

    context 'not existing table' do
      subject{ described_class.rename_column(:invalid_table_name, :column_name, :new_column_name) }
      
      it { expect{subject}.not_to change{validator.reload.column_name} }
    end

    context 'not existing column' do
      subject{ described_class.rename_column(:table_name, :invalid_column_name, :new_column_name) }
      
      it { expect{subject}.not_to change{validator.reload.column_name} }
    end
  end

  describe '#rollback with commit' do
    subject do
      described_class.rollback
      described_class.commit
    end

    context 'delayed save' do
      before { validator.delayed_save }

      it { expect{ subject }.not_to change(described_class, :count) }
    end
    
    context 'delayed destroy' do
      before do 
        validator.save!
        validator.delayed_destroy 
      end

      it { expect{ subject }.not_to change(described_class, :count) }
    end
  end

  describe '#clear with commit' do
    before do
      described_class.create!(table_name: :table_name, 
                              column_name: :column_name, 
                              validator_name: :validator_name_1)
      described_class.new(table_name: :table_name, 
                          column_name: :column_name, 
                          validator_name: :validator_name_2).delayed_save
      validator.save!
      validator.delayed_destroy
    end

    subject{ described_class.clear_all }

    it { expect{ subject }.to change(described_class, :count).from(2).to(0) }
  end

end
