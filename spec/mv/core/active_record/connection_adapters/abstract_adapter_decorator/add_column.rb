RSpec.shared_examples 'abstract_adapter_decorator#add_column' do
  describe '#add_column' do
    include_examples 'abstract_adapter_decorator#add_column#normal'
    include_examples 'abstract_adapter_decorator#add_column#simplified'
    include_examples 'abstract_adapter_decorator#add_column#predefined_email'
  end
end
