# require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

# describe MigrationValidators::Core::ValidatorConstraintsList do
#   subject(:list) { described_class.new(:constraint) }

#   describe '#initialize' do
#     its(:raw_list) { is_expected.to eq(['constraint']) }
#   end

#   describe '#add' do
#     context 'existing constraint' do
#       before { list.add(:constraint) }
      
#       its(:raw_list) { is_expected.to eq(['constraint']) }
#     end

#     context 'new constraint' do
#       before { list.add('constraint_1') }
      
#       its(:raw_list) { is_expected.to match_array(['constraint', 'constraint_1']) }
#     end
#   end

#   describe '#remove' do
#     context 'by symbol' do
#       subject{ list.remove(:constraint) }

#       it 'removes constraint from the list' do
#         expect{ subject }.to change(list.raw_list, :count).by(-1)
#       end
#     end

#     context 'by string' do
#       subject{ list.remove('constraint') }
      
#       it 'removes constraint from the list' do
#         expect{ subject }.to change(list.raw_list, :count).by(-1)
#       end
#     end


#     context 'non existing item' do
#       subject{ list.remove('constraint_1') }
      
#       it 'should not remove element' do
#         expect{ subject }.not_to change(list.raw_list, :count)
#       end
#     end
#   end

#   describe '#include?' do
#     it(:raw_list) { is_expected.to include('constraint') }
#     it(:raw_list) { is_expected.to include(:constraint) }
#     it(:raw_list) { is_expected.not_to include(:constraint_1) }
#   end
# end
