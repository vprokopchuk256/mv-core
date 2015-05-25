RSpec.shared_examples 'abstract_adapter_decorator#rename_column' do
  describe '#rename_column' do
    subject do
      conn.rename_column :table_name,
                         :old_column_name,
                         :new_column_name
    end

    it 'removes updates all column validations and column itself' do
      expect(Mv::Core::Migration::Base.current).to receive(:rename_column).with(
        :table_name, :old_column_name, :new_column_name
      )
      expect(original_connection)
        .to receive(:rename_column)
        .with(:table_name, :old_column_name, :new_column_name)

      subject
    end
  end
end
