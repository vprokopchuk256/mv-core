require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe StatementBuilder  do
  subject(:builder) { StatementBuilder.new 'column' }

  describe '#initialize' do
    its(:actions) { is_expected.to be_empty }
    its(:to_s) { is_expected.to eq('column') }
  end

  it_behaves_like :statement_builder

end
