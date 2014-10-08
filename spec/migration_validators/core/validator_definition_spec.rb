require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

ValidatorDefinition = MigrationValidators::Core::ValidatorDefinition

describe ValidatorDefinition, :type => :mv_test  do
  let(:validator) { FactoryGirl.build(:db_validator)}
  subject(:validator_definition) { described_class.new }

  it_behaves_like :statement_builder do
    subject(:builder) { validator_definition }
  end

  before :example do
    use_memory_db
    db.initialize_schema_migrations_table
  end

  before :each do
    validator_definition.operation :and do |stmt, value|
      "#{stmt} AND #{value}"
    end

    validator_definition.operation :or do |stmt, value|
      "#{stmt} OR #{value}"
    end
  end

  describe "with validator" do
    before :each do
      validator_definition.validator = validator
    end
    
    its(:to_s) { is_expected.to eq(validator.column_name)}

    describe '#process' do
      before :each do
        validator.options = { :property_name => :property_value }
      end

      subject{ validator_definition.process(validator) }

      it { is_expected.to be_empty }

      context 'when property handler defined' do
        before do
          validator_definition.property :property_name do |property_value|
            "#{column.and(property_value)}"
          end
        end
        
        it { is_expected.to eq(["#{validator.column_name} AND property_value"]) }
      end

      context 'when post processors are defined' do
        before do 
          validator_definition.property :property_name do |property_value|
            "#{column.and(property_value)}"
          end

          validator_definition.post do
            self.and("some_post_value")
          end

          validator_definition.post :property_name => :property_value do
            self.and("some_post_value_1")
          end

          validator_definition.post "property_name" => :property_value do
            self.and("some_post_value_1")
          end

          validator_definition.post :property_name => :wrong_property_value do
            self.and("some_post_value_2")
          end
        end

        it { is_expected.to eq(["#{validator.column_name} AND property_value AND some_post_value AND some_post_value_1"])}
        
      end

      context 'with default property handler' do
        before do
          validator.options = {}

          validator_definition.property do |property_value|
            "#{column}"
          end
        end

        it { is_expected.to eq(["#{validator.column_name}"]) }
      end

      describe '#bind_to_error' do
        before :each do
          validator_definition.operation :bind_to_error do |stmt, error|
            "SHOW '#{error}' UNLESS (#{stmt})"
          end
        end

        context 'when message is define as validator property' do
          before do 
            validator.options[:message] = :default_message 

            validator_definition.property :property_name do |property_value|
              "#{column.and(property_value)}"
            end
          end
          
          it { is_expected.to eq(["SHOW 'default_message' UNLESS (#{validator.column_name} AND property_value)"]) }
        end

        context 'when message mapping is defined' do
          before do 
            validator.options[:message] = :default_message
            validator.options[:specific_message] = :some_specific_message

            validator_definition.property :property_name, :message => :specific_message do |property_value|
              "#{column.and(property_value)}"
            end
          end
          
          it { is_expected.to eq(["SHOW 'some_specific_message' UNLESS (#{validator.column_name} AND property_value)"]) }
        end
      end

      context 'when options filter is defined' do
        before do    
          validator.options[:property_name_1] = :property_value_1

          validator_definition.property(:property_name) {|property_value| "#{column.and(property_value)}"}
          validator_definition.property(:property_name_1) {|property_value| "#{column.and(property_value)}"}
        end

        subject{ validator_definition.process(validator, [:property_name]) }

        it { is_expected.to eq(["#{validator.column_name} AND property_value"]) }
      end
    end
  end
end
