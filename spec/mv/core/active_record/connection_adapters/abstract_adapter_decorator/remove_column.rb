RSpec.shared_examples 'abstract_adapter_decorator#remove_column' do
  describe '#remove_column' do
    subject do
      conn.remove_column :table_name,
                         :column_name,
                         :column_type,
                         column_attr_name: :column_attr_value
    end

    it 'removes all column validations and column itself' do
      expect(Mv::Core::Migration::Base.current).to receive(:remove_column).with(
        :table_name, :column_name
      )
      expect(original_connection)
        .to receive(:remove_column)
        .with(:table_name, :column_name, :column_type, column_attr_name: :column_attr_value)

      subject
    end
  end
end
