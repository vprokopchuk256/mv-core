
# StatementBuilder = MigrationValidators::Core::StatementBuilder

# shared_examples :statement_builder do
#   describe '#operation' do
#     before { builder.operation(:and) {|stmt, value| "#{stmt} and #{value}" } }

#     context 'single' do
#       subject{ builder.and('column_1') }

#       it { expect{ subject }.to change{ builder.to_s }.from(builder.to_s).to("#{builder.to_s} and column_1") }
#     end

#     context 'chanined' do
#       before { builder.operation(:or) {|stmt, value| "#{stmt} or #{value}" } }
      
#       subject{ builder.and('column_1').or('column_2') }

#       it { expect{ subject }.to change{ builder.to_s }.from(builder.to_s).to("#{builder.to_s} and column_1 or column_2") }
#     end
#   end

#   describe '#compile' do
#     subject{ builder.compile('column_1') }

#     it { is_expected.to be_a(StatementBuilder) }
#     it { is_expected.not_to eq(builder) }
#     its(:to_s) { is_expected.to eq('column_1') }
#   end

#   describe '#merge!' do
#     let(:builder1) { described_class.new }

#     before { builder1.operation(:or) {|stmt, value| "#{stmt} or #{value}"}}

#     subject do 
#       builder.merge!(builder1) 
#       builder.or('column_1')
#     end

#     it { expect{ subject }.to change{ builder.to_s }.from(builder.to_s).to("#{builder.to_s} or column_1") }
#   end
# end