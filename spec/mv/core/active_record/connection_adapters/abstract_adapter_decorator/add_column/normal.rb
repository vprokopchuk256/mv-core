RSpec.shared_examples 'abstract_adapter_decorator#add_column#normal' do
  describe 'normal case' do
    subject do
      conn.add_column :table_name,
                      :column_name,
                      :column_type,
                      column_attr_name: :column_attr_value,
                      validates: { presence: true }
    end

    it "initiates validation handling and delegates non validation params to original conn" do
      expect(Mv::Core::Migration::Base.current)
        .to receive(:add_column)
        .with(:table_name, :column_name, presence: true)
      expect(original_connection)
        .to receive(:add_column)
        .with(:table_name, :column_name, :column_type, column_attr_name: :column_attr_value)

      subject
    end
  end
end
