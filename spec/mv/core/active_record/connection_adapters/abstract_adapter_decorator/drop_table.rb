RSpec.shared_examples 'abstract_adapter_decorator#drop_table' do
  describe '#drop_table' do
    subject do
      conn.drop_table :table_name, id: false do |t|
        t.string :column_name
      end
    end

    it 'calls migration method and original one' do
      expect(Mv::Core::Migration::Base.current)
        .to receive(:drop_table)
        .with(:table_name)
      expect(original_connection)
        .to receive(:drop_table)
        .with(:table_name, id: false)

      subject
    end
  end
end
