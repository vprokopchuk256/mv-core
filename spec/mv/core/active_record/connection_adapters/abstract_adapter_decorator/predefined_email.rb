RSpec.shared_examples 'abstract_adapter_decorator#add_column#predefined_email' do
  describe 'predefined email' do
    context 'as column type' do
      subject { conn.add_column :table_name, :column_name, :email, {} }

      it "creates nullable validation and delegates non validation params to original conn" do
        expect(Mv::Core::Migration::Base.current)
          .to receive(:add_column)
          .with(:table_name, :column_name, format: { with: instance_of(Regexp), allow_nil: true})
        expect(original_connection)
          .to receive(:add_column)
          .with(:table_name, :column_name, :string, {})

        subject
      end
    end

    context 'simplification' do
      subject do
        conn.add_column :table_name,
                        :column_name,
                        :column_type,
                        email: true
      end

      it "creates nullable validation and delegates non validation params to original conn" do
        expect(Mv::Core::Migration::Base.current)
          .to receive(:add_column)
          .with(:table_name, :column_name, format: { with: instance_of(Regexp), allow_nil: true})
        expect(original_connection)
          .to receive(:add_column)
          .with(:table_name, :column_name, :column_type, {})

        subject
      end
    end

    context 'standard form' do
      context 'column is nullable' do
        subject do
          conn.add_column :table_name,
                          :column_name,
                          :column_type,
                          validates: { email: true }
        end

        it "creates nullable validation and delegates non validation params to original conn" do
          expect(Mv::Core::Migration::Base.current)
            .to receive(:add_column)
            .with(:table_name, :column_name, format: { with: instance_of(Regexp), allow_nil: true})
          expect(original_connection)
            .to receive(:add_column)
            .with(:table_name, :column_name, :column_type, {})

          subject
        end
      end

      context 'column is NOT nullable' do
        subject do
          conn.add_column :table_name,
                          :column_name,
                          :column_type,
                          null: false,
                          validates: { email: true }
        end

        it "creates nullable validation and delegates non validation params to original conn" do
          expect(Mv::Core::Migration::Base.current)
            .to receive(:add_column)
            .with(:table_name, :column_name, format: instance_of(Regexp))
          expect(original_connection)
            .to receive(:add_column)
            .with(:table_name, :column_name, :column_type, { null: false })

          subject
        end
      end

      context 'column is not nullable but nulls are not allowed' do
        subject do
          conn.add_column :table_name,
                          :column_name,
                          :column_type,
                          null: false,
                          validates: { email: { allow_nil: false, allow_blank: false } }
        end

        it "creates nullable validation and delegates non validation params to original conn" do
          expect(Mv::Core::Migration::Base.current)
            .to receive(:add_column)
            .with(:table_name,
                  :column_name,
                  format: { with: instance_of(Regexp), allow_nil: false, allow_blank: false } )
          expect(original_connection)
            .to receive(:add_column)
            .with(:table_name, :column_name, :column_type, { null: false })

          subject
        end
      end
    end
  end
end
