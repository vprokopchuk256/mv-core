RSpec.shared_examples 'abstract_adapter_decorator#change_column' do
  describe '#change_column' do
    context 'when normal validation form provided' do
      subject do
        conn.change_column :table_name,
                           :column_name,
                           :column_type,
                           column_attr_name: :column_attr_value,
                           validates: { length: { is: 5 } }
      end

      it 'calls migration method and original one' do
        expect(Mv::Core::Migration::Base.current)
          .to receive(:change_column)
          .with(:table_name, :column_name, length: { is: 5 })
        expect(original_connection)
          .to receive(:change_column)
          .with(:table_name, :column_name, :column_type, column_attr_name: :column_attr_value)

        subject
      end
    end

    context 'when simplified validation form provided' do
      subject do
        conn.change_column :table_name,
                           :column_name,
                           :column_type,
                           column_attr_name: :column_attr_value,
                           length: { is: 5 }
      end

      it 'calls migration method and original one' do
        expect(Mv::Core::Migration::Base.current)
          .to receive(:change_column)
          .with(:table_name, :column_name, length: { is: 5 })
        expect(original_connection)
          .to receive(:change_column)
          .with(:table_name, :column_name, :column_type, column_attr_name: :column_attr_value)

        subject
      end
    end
  end
end
