# require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

# AbstractAdapter = ::ActiveRecord::ConnectionAdapters::AbstractAdapter
# DbValidator = ::MigrationValidators::Core::DbValidator

# describe ::ActiveRecord::ConnectionAdapters::AbstractAdapter, "migration validators extension", :type => :mv_test do
#   let(:migrations_table_name) { ::ActiveRecord::Migrator::schema_migrations_table_name }
#   let(:validators_table_name) { MigrationValidators.migration_validators_table_name }

#   before :example do
#     use_memory_db
#   end

#   before :each do
#     MigrationValidators::Core::DbValidator.rollback
#   end

#   describe '#initialize_migration_validators_table' do
#     subject { db.initialize_migration_validators_table }

#     context 'when it does not exists initially' do
#       before :each do
#         db.drop_table validators_table_name if db.table_exists?(validators_table_name)
#       end

#       it { expect{ subject }.to change{ db.table_exists?(validators_table_name) }.from(false).to(true) }
#     end

#     context 'when it already exists' do
#       before :each do
#         db.initialize_migration_validators_table
#       end

#       it { expect{ subject }.not_to raise_error}
#     end
#   end


#   describe "synchronization with schema statements" do
#     before :each do
#       db.initialize_schema_migrations_table
#       db.do_internally do
#         db.drop_table :new_table_name if db.table_exists?(:new_table_name)
#         db.drop_table :table_name if db.table_exists?(:table_name)
#         db.create_table(:table_name) do |t|
#           t.string :column_name 
#           t.string :column_name1
#         end 
#       end

#       DbValidator.delete_all
#     end

#     describe '#drop_table' do
#       before do
#         db.validate_column(:table_name, :column_name, uniqueness: { message: "some message"})
#         DbValidator.commit
#       end

#       subject do 
#         db.drop_table( :table_name ) 
#         DbValidator.commit
#       end
      
#       it { expect{ subject }.to change{ DbValidator.on_table(:table_name).count }.from(1).to(0) }
#       it { expect{ subject }.to change{ db.table_exists?(:table_name) }.from(true).to(false) }
#     end

#     describe '#remove_column' do
#       before do
#         db.validate_column(:table_name, :column_name, uniqueness: { message: "some message"})
#         DbValidator.commit
#       end

#       subject do 
#         db.remove_column(:table_name, :column_name) 
#         DbValidator.commit
#       end

#       it { expect{ subject }.to change(DbValidator, :count).by(-1) }
#       it { expect{ subject }.to change{ db.column_exists?(:table_name, :column_name) }.from(true).to(false) }
#     end

#     describe '#rename_column' do
#       before do
#         db.validate_column(:table_name, :column_name, uniqueness: { message: "some message"})
#         DbValidator.commit
#       end

#       subject do 
#         db.rename_column(:table_name, :column_name, :new_column_name) 
#         DbValidator.commit
#       end

#       it { expect{ subject }.not_to change(DbValidator, :count) }
#       it { expect{ subject }.to change{ DbValidator.on_table(:table_name).first.column_name }.from('column_name').to('new_column_name') }
#     end

#     describe '#rename_table' do
#       before do
#         db.validate_column(:table_name, :column_name, uniqueness: { message: "some message"})
#         DbValidator.commit
#       end

#       subject do 
#         db.rename_table(:table_name, :new_table_name)
#         DbValidator.commit
#       end

#       it { expect{ subject }.not_to change(DbValidator, :count) }
#       it { expect{ subject }.to change{ DbValidator.first.table_name }.from('table_name').to('new_table_name') }
#     end

#     describe '#add_column' do
#       subject :each do
#         db.add_column :table_name, :new_column, :integer, :validates => {:uniqueness => true}
#         DbValidator.commit
#       end

#       it { expect{ subject }.to change{DbValidator.on_table(:table_name).on_column(:new_column).count}.from(0).to(1) }
#       it { expect{ subject }.to change{ db.column_exists?(:table_name, :new_column) }.from(false).to(true) }
#     end

#     describe '#change_column' do
#       before :each do
#         db.add_column :table_name, :new_column, :integer, :validates => {:uniqueness => true}
#         DbValidator.commit
#         db.change_column :table_name, :new_column, :string, :validates => {:presence => true}
#         DbValidator.commit
#       end

#       context 'column' do
#         subject{ db.columns(:table_name).find{|col| col.name.to_sym == :new_column} }

#         its(:type) { is_expected.to eq(:string) }
#       end

#       context 'validator' do
#         subject { DbValidator.on_table(:table_name).on_column(:new_column).first }

#         its(:validator_name) { is_expected.to eq('presence')}
#       end
#     end

#     describe '#create_table' do
#       before :each do
#         db.drop_table :new_table if db.table_exists?(:new_table)
#         DbValidator.commit
#       end

#       subject do 
#         db.create_table :new_table do |t|
#           t.column :column, :string, :validates => {:presence => true} 
#         end
#         DbValidator.commit
#       end

#       it { expect{ subject }.to change{ DbValidator.on_table(:new_table).on_column(:column).count }.from(0).to(1) }
#       it { expect{ subject }.to change{ db.table_exists?(:new_table) }.from(false).to(true) }
#     end
#   end

#   describe '#change_table' do
#     describe "existing_columns" do
#       before :each do
#         db.initialize_schema_migrations_table
#         db.drop_table :new_table if db.table_exists?(:new_table)
#         db.create_table(:new_table) do |t| 
#           t.string :column
#           t.string :column_1
#         end
#         DbValidator.commit
#       end

#       context 'create' do
#         subject do
#           db.change_table :new_table do |t|
#             t.column :new_column, :string, :validates => {:presence => true} 
#           end
#           DbValidator.commit
#         end
        
#         it { expect{ subject }.to change{ DbValidator.on_table(:new_table).on_column(:new_column).count }.from(0).to(1) }
#         it { expect{ subject }.to change{ db.column_exists?(:new_table, :new_column) }.from(false).to(true) }
#       end

#       context 'remove' do
#         before do
#           db.change_table :new_table do |t|
#             t.change :column, :string, validates: { presence: true }
#           end
#           DbValidator.commit
#         end

#         subject do
#           db.change_table :new_table do |t|
#             t.remove :column
#           end
#           DbValidator.commit
#         end
        
#         it { expect{ subject }.to change{ DbValidator.on_table(:new_table).on_column(:column).count }.from(1).to(0) }
#         it { expect{ subject }.to change{ db.column_exists?(:new_table, :column) }.from(true).to(false) }
#       end

#       context 'change_validates' do
#         before do
#           db.change_table :new_table do |t|
#             t.change :column, :string, validates: { presence: true }
#           end
#           DbValidator.commit
#         end

#         subject do
#           db.change_table :new_table do |t|
#             t.change_validates :column, presence: false, uniqueness: true
#           end
#           DbValidator.commit
#         end
        
#         it do 
#           expect{ subject }.to change{ 
#             DbValidator.on_table(:new_table).on_column(:column).first.validator_name
#           }.from('presence').to('uniqueness') 
#         end
#       end

#       context 'change' do
#         context 'type' do
#           subject do
#             db.change_table :new_table do |t|
#               t.change :column, :integer
#             end
#             DbValidator.commit
#           end

#           it { expect{ subject }.to change{ db.columns(:new_table).find{|col| col.name.to_sym == :column}.type }.from(:string).to(:integer) }
#         end

#         context 'add validator' do
#           subject do
#             db.change_table :new_table do |t|
#               t.change :column, :string, validates: { presence: true }
#             end
#             DbValidator.commit
#           end

#           it { expect{ subject }.to change{ DbValidator.on_table(:new_table).on_column(:column).count }.from(0).to(1) }
#         end

#         context 'remove validator' do
#           before do
#             db.change_table :new_table do |t|
#               t.change :column, :string, validates: { presence: true }
#             end
#             DbValidator.commit
#           end

#           subject do
#             db.change_table :new_table do |t|
#               t.change :column, :string
#             end
#             DbValidator.commit
#           end

#           it { expect{ subject }.to change{ DbValidator.on_table(:new_table).on_column(:column).count }.from(1).to(0) }
#         end

#         context 'update validator' do
#           before do
#             db.change_table :new_table do |t|
#               t.change :column, :string, validates: { presence: true }
#             end
#             DbValidator.commit
#           end

#           subject do
#             db.change_table :new_table do |t|
#               t.change :column, :string, validates: { uniqueness: true }
#             end
#             DbValidator.commit
#           end

#           it do 
#             expect{ subject }.to change{ 
#               DbValidator.on_table(:new_table).on_column(:column).first.validator_name
#             }.from('presence').to('uniqueness') 
#           end
#         end
#       end
#     end
#   end

#   describe '#validate_column' do
#     before do
#       db.initialize_schema_migrations_table
#       db.create_table(:table_name) do |t|
#         t.string :column_name 
#       end unless db.table_exists?(:table_name)
#     end

#     context 'new validator is defined' do
#       before do
#         db.validate_column :table_name, 
#                            :column_name, 
#                            :uniqueness => {:message => "unique"}
#         DbValidator.commit
#       end

#       subject{ DbValidator.on_table(:table_name).on_column(:column_name).with_name(:uniqueness).first }

#       it { is_expected.to be_present }
#       its(:options) { is_expected.to eq(message: 'unique') }
#     end 

#     context 'when validator option is not defined' do
#       subject do
#         db.validate_column :table_name, 
#                            :column_name, 
#                            {}
#         DbValidator.commit
#       end

#       it { expect{ subject }.to raise_error }
#     end

#     context 'new validator are defined as true' do
#       before do
#         db.validate_column :table_name, 
#                            :column_name, 
#                            :uniqueness => true
#         DbValidator.commit
#       end

#       subject{ DbValidator.on_table(:table_name).on_column(:column_name).with_name(:uniqueness).first }

#       it { is_expected.to be_present }
#       its(:options) { is_expected.to be_blank }
#     end 

#     context 'new validator are defined as false' do
#       before do
#         db.validate_column :table_name, 
#                            :column_name, 
#                            :uniqueness => true
#         DbValidator.commit

#         db.validate_column :table_name, 
#                            :column_name, 
#                            :uniqueness => false
#         DbValidator.commit
#       end

#       subject{ DbValidator.on_table(:table_name).on_column(:column_name).with_name(:uniqueness).first }

#       it { is_expected.to be_nil }
#     end 
#   end

#   describe '#in_context_of_table' do
#     before do
#       db.initialize_schema_migrations_table
#       db.create_table(:table_name) do |t|
#         t.string :column_name 
#       end unless db.table_exists?(:table_name)

#       db.in_context_of_table :table_name do
#         db.validate_column nil, 
#                            :column_name, 
#                            :uniqueness => true 
#         DbValidator.commit
#       end
#     end

#     subject{ DbValidator.on_table(:table_name).on_column(:column_name).with_name(:uniqueness).first }

#     it { is_expected.to be_present }
#     its(:table_name) { is_expected.to eq('table_name') }
#   end
# end
