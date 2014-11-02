require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe MigrationValidators::Adapters::Base, :type => :mv_test do
  before :all do
    use_memory_db
    db.initialize_schema_migrations_table
  end

  context 'syntax' do
    before{ described_class.define_base_syntax }

    subject(:syntax) { described_class.syntax.compile('column_name') }

    context 'operation #db_name' do
      subject{ syntax.db_name } 

      its(:to_s) { is_expected.to eq("column_name") }
    end

    context 'operation #db_value' do
      subject{ syntax.db_value } 

      its(:to_s) { is_expected.to eq("column_name") }
    end

    context 'operation #wrap' do
      subject{ syntax.wrap } 

      its(:to_s) { is_expected.to eq("(column_name)") }
    end

    context 'operation #and' do
      subject{ syntax.and('column_name_1') }
      
      its(:to_s) { is_expected.to eq("column_name AND column_name_1") }
    end

    context 'operation #or' do
      subject{ syntax.or('column_name_1') }
      
      its(:to_s) { is_expected.to eq("column_name OR column_name_1") }
    end

    context 'operation #length' do
      subject{ syntax.length }
      
      its(:to_s) { is_expected.to eq("LENGTH(column_name)") }
    end

    context 'operation for #trim' do 
      subject{ syntax.trim }

      its(:to_s) { is_expected.to eq("TRIM(column_name)") }
    end

    context 'operation for #coalesce' do 
      subject{ syntax.coalesce }

      its(:to_s) { is_expected.to eq("COALESCE(column_name, '')") }
    end

    context 'operation for #if' do 
      subject{ syntax.if('column_name_1') }

      its(:to_s) { is_expected.to eq("IF column_name THEN column_name_1 ENDIF") }
    end

    context 'operation for #regexp' do 
      subject{ syntax.regexp('column_name_1') }

      its(:to_s) { is_expected.to eq("column_name REGEXP column_name_1") }
    end

    context 'operation for #greater_than' do 
      subject{ syntax.greater_than('column_name_1') }

      its(:to_s) { is_expected.to eq("column_name > column_name_1") }
    end

    context 'operation for #greater_or_equal_to' do 
      subject{ syntax.greater_or_equal_to('column_name_1') }

      its(:to_s) { is_expected.to eq("column_name >= column_name_1") }
    end

    context 'operation for #less_than' do 
      subject{ syntax.less_than('column_name_1') }

      its(:to_s) { is_expected.to eq("column_name < column_name_1") }
    end

    context 'operation for #less_or_equal_to' do 
      subject{ syntax.less_or_equal_to('column_name_1') }

      its(:to_s) { is_expected.to eq("column_name <= column_name_1") }
    end

    context 'operation for #equal_to' do 
      subject{ syntax.equal_to('column_name_1') }

      its(:to_s) { is_expected.to eq("column_name = column_name_1") }
    end

    context 'operation for #between' do 
      context 'open range' do
        subject{ syntax.between(1...2) }
        
        its(:to_s) { is_expected.to eq("column_name >= 1 AND column_name < 2") }
      end

      context 'closed range' do
        subject{ syntax.between(1..2) }
        
        its(:to_s) { is_expected.to eq("column_name >= 1 AND column_name <= 2") }
      end
    end

    context 'operation for #in' do 
      subject{ syntax.in([1,2]) }

      its(:to_s) { is_expected.to eq("column_name IN (1, 2)") }
    end

    context 'operation for #not_in' do 
      subject{ syntax.not_in([1,2]) }

      its(:to_s) { is_expected.to eq("column_name NOT IN (1, 2)") }
    end

    context 'operation for #not_null' do 
      subject{ syntax.not_null }

      its(:to_s) { is_expected.to eq("column_name IS NOT NULL") }
    end

    context 'operation for #null' do 
      subject{ syntax.null }

      its(:to_s) { is_expected.to eq("column_name IS NULL") }
    end

    context 'operation for #not' do 
      subject{ syntax.not }

      its(:to_s) { is_expected.to eq("NOT column_name") }
    end

    context 'operation for #exists' do 
      subject{ syntax.exists }

      its(:to_s) { is_expected.to eq("EXISTS column_name") }
    end

    context 'operation for #select' do 
      subject{ syntax.select }

      its(:to_s) { is_expected.to eq("SELECT column_name") }
    end

    context 'operation for #from' do 
      subject{ syntax.from }

      its(:to_s) { is_expected.to eq(" FROM column_name") }
    end

    context 'operation for #where' do 
      subject{ syntax.where }

      its(:to_s) { is_expected.to eq("WHERE column_name") }
    end
  end

  context 'validator definitions' do
    let(:validator_name) { |example| example.metadata[:validator_name] }
    let(:options) { |example| example.metadata[:options] }

    let(:validator) { DbValidator.new(validator_name: validator_name, 
                                      table_name: :table_name, 
                                      column_name: :column_name, 
                                      options: options) }

    before{ described_class.define_base_validators }

    subject do 
      validator_definition = described_class.validators[validator_name]
      validator_definition.process(validator)
      validator_definition.to_s
    end

    context 'inclusion', validator_name: :inclusion do
      context 'when nil and blank are not allowed', options: { :in => 1..2 } do
        it do 
          is_expected.to eq("column_name IS NOT NULL AND column_name >= 1 AND column_name <= 2") 
        end
      end

      context 'when range is open', options: { :in => 1...2 } do
        it do 
          is_expected.to eq("column_name IS NOT NULL AND column_name >= 1 AND column_name < 2") 
        end
      end

      context 'when nil and blank are allowed', options: { :in => 1..2, allow_nil: true, allow_blank: true} do
        it do 
          is_expected.to eq("((column_name IS NOT NULL AND column_name >= 1 AND column_name <= 2) OR column_name IS NULL) OR LENGTH(TRIM(COALESCE(column_name, ''))) = 0") 
        end
      end
    end

    context 'exclusion', validator_name: :exclusion do
      context 'when nil and blank are NOT allowed', options: { :in => 1..2 } do
        it do 
          is_expected.to eq("NOT (column_name >= 1 AND column_name <= 2)")
        end
      end

      context 'when range is open', options: { :in => 1...2 } do
        it do 
          is_expected.to eq("NOT (column_name >= 1 AND column_name < 2)")
        end
      end

      context 'when nil and blank are allowed', options: { :in => 1..2, allow_nil: true, allow_blank: true} do
        it do 
          is_expected.to eq("((NOT (column_name >= 1 AND column_name <= 2)) OR column_name IS NULL) OR LENGTH(TRIM(COALESCE(column_name, ''))) = 0")
        end
      end
    end

    context 'format', validator_name: :format do
      context 'when nil and blank are NOT allowed', options: { :with => '*txt*' } do
        it do 
          is_expected.to eq("column_name IS NOT NULL AND column_name REGEXP *txt*")
        end
      end

      context 'when nil and blank are allowed', options: { :with => '*txt*', allow_nil: true, allow_blank: true} do
        it do 
          is_expected.to eq("((column_name IS NOT NULL AND column_name REGEXP *txt*) OR column_name IS NULL) OR LENGTH(TRIM(COALESCE(column_name, ''))) = 0")
        end
      end
    end

    context 'length', validator_name: :length do
      context 'when nil and blank are allowed', options: { is: 5, allow_nil: true, allow_blank: true} do
        it do 
          is_expected.to eq("((LENGTH(COALESCE(column_name, '')) = 5) OR column_name IS NULL) OR LENGTH(TRIM(COALESCE(column_name, ''))) = 0")
        end
      end

      context 'property #is', options: { is: 5} do
        it do 
          is_expected.to eq("LENGTH(COALESCE(column_name, '')) = 5")
        end
      end

      context 'property #maximum', options: { maximum: 5} do
        it do 
          is_expected.to eq("LENGTH(COALESCE(column_name, '')) <= 5")
        end
      end

      context 'property #minimum', options: { minimum: 5} do 
        it do 
          is_expected.to eq("LENGTH(COALESCE(column_name, '')) >= 5")
        end
      end

      context 'property #in', options: { :in => 1..5 } do
        it do 
          is_expected.to eq("LENGTH(COALESCE(column_name, '')) >= 1 AND LENGTH(COALESCE(column_name, '')) <= 5")
        end
      end

      context 'property #within', options: { within: 1..5 } do
        it do 
          is_expected.to eq("LENGTH(COALESCE(column_name, '')) >= 1 AND LENGTH(COALESCE(column_name, '')) <= 5")
        end
      end
    end

    context 'size', validator_name: :size do
      context 'when nil and blank are allowed', options: { is: 5, allow_nil: true, allow_blank: true} do
        it do 
          is_expected.to eq("((LENGTH(COALESCE(column_name, '')) = 5) OR column_name IS NULL) OR LENGTH(TRIM(COALESCE(column_name, ''))) = 0")
        end
      end

      context 'property #is', options: { is: 5} do
        it do 
          is_expected.to eq("LENGTH(COALESCE(column_name, '')) = 5")
        end
      end

      context 'property #maximum', options: { maximum: 5} do
        it do 
          is_expected.to eq("LENGTH(COALESCE(column_name, '')) <= 5")
        end
      end

      context 'property #minimum', options: { minimum: 5} do 
        it do 
          is_expected.to eq("LENGTH(COALESCE(column_name, '')) >= 5")
        end
      end

      context 'property #in', options: { :in => 1..5 } do
        it do 
          is_expected.to eq("LENGTH(COALESCE(column_name, '')) >= 1 AND LENGTH(COALESCE(column_name, '')) <= 5")
        end
      end

      context 'property #within', options: { within: 1..5 } do
        it do 
          is_expected.to eq("LENGTH(COALESCE(column_name, '')) >= 1 AND LENGTH(COALESCE(column_name, '')) <= 5")
        end
      end
    end

    context 'presence', validator_name: :presence, options: {} do
      it do 
        is_expected.to eq("column_name IS NOT NULL AND LENGTH(TRIM(column_name)) > 0")
      end
    end

    context 'uniqueness', validator_name: :uniqueness, options: {} do
      it do 
        is_expected.to eq("NOT EXISTS(SELECT column_name FROM table_name tbl WHERE (column_name = column_name))")
      end
    end
  end

  context 'containers' do
    let(:container_name) { |example| example.metadata[:container_name] }

    let(:validators) { [DbValidator.new(validator_name: :length, 
                                        table_name: :table_name, 
                                        column_name: :column_name, 
                                        options: { is: 5 })] }

    before { described_class.define_base_containers }

    subject do 
      container = described_class.containers[container_name] 
      container.add_validators(validators)
    end
    
    context 'insert_trigger', container_name: :insert_trigger do
      it do
        should eq([
          "DROP TRIGGER IF EXISTS trg_mgr_validates_table_name_ins;", 
          "CREATE TRIGGER trg_mgr_validates_table_name_ins BEFORE INSERT ON table_name FOR EACH ROW BEGIN LENGTH(COALESCE(NEW.column_name, '')) = 5;  END;"
        ])
      end
    end

    context 'update_trigger', container_name: :update_trigger do
      it do
        should eq([
          "DROP TRIGGER IF EXISTS trg_mgr_validates_table_name_upd;", 
          "CREATE TRIGGER trg_mgr_validates_table_name_upd BEFORE UPDATE ON table_name FOR EACH ROW BEGIN LENGTH(COALESCE(NEW.column_name, '')) = 5;  END;"
        ])
      end
    end

    context 'check', container_name: :check do
      it do
        should eq([
          "ALTER TABLE table_name DROP CONSTRAINT chk_table_name_column_name;", 
          "ALTER TABLE table_name ADD CONSTRAINT chk_table_name_column_name CHECK(LENGTH(COALESCE(column_name, '')) = 5);"
        ])
      end
    end
  end

  context 'routes' do
    
  end
end
