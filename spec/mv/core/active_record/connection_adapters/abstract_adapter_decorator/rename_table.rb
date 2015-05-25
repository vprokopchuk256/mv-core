RSpec.shared_examples 'abstract_adapter_decorator#rename_table' do
  describe '#rename_table' do
    subject do
      conn.rename_table :old_table_name, :new_table_name
    end

    it 'calls migration method and original one' do
      expect(Mv::Core::Migration::Base.current)
        .to receive(:rename_table)
        .with(:old_table_name, :new_table_name)
      expect(original_connection)
        .to receive(:rename_table)
        .with(:old_table_name, :new_table_name)

      subject
    end
  end
end
