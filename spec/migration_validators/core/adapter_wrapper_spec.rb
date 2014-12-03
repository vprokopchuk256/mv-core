# require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

# describe MigrationValidators::Core::AdapterWrapper, :type => :mv_test do
#   let(:wrapper) { MigrationValidators::Core::AdapterWrapper.new MigrationValidators::Spec::Support::TestAdapter.new }

#   before :each do
#     use_memory_db
#     db.initialize_schema_migrations_table
#     MigrationValidators::Spec::Support::TestAdapter.clear
#   end

#   describe '#create_validators' do
#     context "calls driver method if such validator is supported" do
#       let(:validator) { FactoryGirl.build :uniqueness_check }

#       before do
#         MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :uniqueness, :check
#         wrapper.create_validators [validator]
#       end

#       subject{ MigrationValidators::Spec::Support::TestAdapter.log[:validate_uniqueness_check] }

#       it { is_expected.to be_present }
#       its(:first) { is_expected.to eq([validator])}
#     end

#     context "groups validators by table_name, validator_name and db form" do
#       let(:validator1) { FactoryGirl.build :presence_check, :column_name => :column_name_1 }
#       let(:validator2) { FactoryGirl.build :presence_check, :column_name => :column_name_2 }

#       before do
#         MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :presence, :check
#         wrapper.create_validators [validator1, validator2]
#       end

#       subject{ MigrationValidators::Spec::Support::TestAdapter.log[:validate_presence_check] }


#       its(:first) { is_expected.to eq([validator1, validator2]) }
#     end

#     context "calls driver method until all validatos are created if not all validators were handled" do
#       let(:validator1) { FactoryGirl.build :uniqueness_check, :column_name => :column_name_1 }
#       let(:validator2) { FactoryGirl.build :uniqueness_check, :column_name => :column_name_2 }

#       before do 
#         MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :uniqueness, :check do |validators|
#           [validators.first]
#         end

#         wrapper.create_validators [validator1, validator2]
#       end

#       subject{ MigrationValidators::Spec::Support::TestAdapter.log[:validate_uniqueness_check] }

#       its(:first) { is_expected.to eq([validator1, validator2]) }
#       its(:last) { is_expected.to eq([validator2]) }
#     end

#     context "raises an exception is driver does not support specified validator" do
#       let(:validator) { FactoryGirl.build :uniqueness_check }

#       before{ MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :presence, :check }

#       it do
#         expect{
#           wrapper.create_validators [validator]
#         }.to raise_error MigrationValidators::MigrationValidatorsException, /Action 'validate' for 'uniqueness' is not supported. Available validators: \['presence'\]/
#       end
#     end

#     context "raises an exception if driver does not support default db form for specified validator" do
#       let(:validator) { FactoryGirl.build :presence }

#       before { MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :presence, :check }

#       it do
#         expect{
#           wrapper.create_validators [validator]
#         }.to raise_error MigrationValidators::MigrationValidatorsException, /Action 'validate' for 'presence' with default db form is not supported/
#       end
#     end

#     context "raises an exception is driver does not support specified validator in specified db form" do
#       let(:validator) { FactoryGirl.build :uniqueness_check }

#       before{ MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :uniqueness, :trigger }

#       it do
#         expect{
#           wrapper.create_validators [validator]
#         }.to raise_error MigrationValidators::MigrationValidatorsException, /Action 'validate' for db form 'check' for validator 'uniqueness' is not supported. Available db forms: \['trigger'\]/
#       end
#     end

#     context "handles omitted db form" do
#       let(:validator) { FactoryGirl.build :uniqueness }

#       before do 
#         MigrationValidators::Spec::Support::TestAdapter.stub_validate_method :uniqueness 
#         wrapper.create_validators [validator]
#       end

#       subject{ MigrationValidators::Spec::Support::TestAdapter.log[:validate_uniqueness] }

#       its(:first) { is_expected.to eq([validator]) }
#     end
#   end

#   describe :remove_validators do
#     context "calls driver method if such validator remove is supported" do
#       let(:validator) { FactoryGirl.build :uniqueness_check }

#       before do
#         MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :uniqueness, :check
#         wrapper.remove_validators [validator]
#       end

#       subject{ MigrationValidators::Spec::Support::TestAdapter.log[:remove_validate_uniqueness_check] }

#       it { is_expected.to be_present }
#       its(:first) { is_expected.to eq([validator]) }
#     end

#     context "groups validators by table_name, validator_name and db form" do
#       let(:validator1) { FactoryGirl.build :presence_check, :column_name => :column_name_1 }
#       let(:validator2) { FactoryGirl.build :presence_check, :column_name => :column_name_2 }

#       before do
#         MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :presence, :check
#         wrapper.remove_validators [validator1, validator2]
#       end

#       subject{ MigrationValidators::Spec::Support::TestAdapter.log[:remove_validate_presence_check] }

#       its(:first) { is_expected.to eq([validator1, validator2]) }
#     end

#     context "calls driver method until all validatos are removed if not all validators were handled" do
#       let(:validator1) { FactoryGirl.build :uniqueness_check, :column_name => :column_name_1 }
#       let(:validator2) { FactoryGirl.build :uniqueness_check, :column_name => :column_name_2 }

#       before do
#         MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :uniqueness, :check do |validators|
#           [validators.first]
#         end
#         wrapper.remove_validators [validator1, validator2]
#       end

#       subject{ MigrationValidators::Spec::Support::TestAdapter.log[:remove_validate_uniqueness_check] }

#       its(:first) { is_expected.to eq([validator1, validator2]) }
#       its(:last) { is_expected.to eq([validator2]) }
#     end

#     context "raises an exception is driver does not support removing of the specified validator" do
#       let(:validator) { FactoryGirl.build :uniqueness_check }

#       before{ MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :presence, :check }

#       it do
#         expect {
#           wrapper.remove_validators [validator]
#         }.to raise_error MigrationValidators::MigrationValidatorsException, /Action 'remove_validate' for 'uniqueness' is not supported. Available validators: \['presence'\]/
#       end
#     end

#     context "raises an exception if driver does not support removing validator with in default db form" do
#       let(:validator) { FactoryGirl.build :presence }

#       before{ MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :presence, :check }

#       it do
#         expect {
#           wrapper.remove_validators [validator]
#         }.to raise_error MigrationValidators::MigrationValidatorsException, /Action 'remove_validate' for 'presence' with default db form is not supported/
#       end
#     end

#     context "raises an exception is driver does not support specified removing validator in specified db form" do
#       let(:validator) { FactoryGirl.build :uniqueness_check }

#       before{ MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :uniqueness, :trigger }

#       it do
#         expect {
#           wrapper.remove_validators [validator]
#         }.to raise_error MigrationValidators::MigrationValidatorsException, /Action 'remove_validate' for db form 'check' for validator 'uniqueness' is not supported. Available db forms: \['trigger'\]/
#       end
#     end

#     context "handles omitted db form" do
#       let(:validator) { FactoryGirl.build :uniqueness }

#       before do
#         MigrationValidators::Spec::Support::TestAdapter.stub_remove_validate_method :uniqueness 
#         wrapper.remove_validators [validator]
#       end

#       subject{ MigrationValidators::Spec::Support::TestAdapter.log[:remove_validate_uniqueness] }

#       its(:first) { is_expected.to eq([validator]) }
#     end
#   end
# end
