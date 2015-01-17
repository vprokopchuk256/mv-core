require 'spec_helper'

require 'mv/core/services/create_migration_validators_table'
require 'mv/core/services/show_constraints'

describe Mv::Core::Services::ShowConstraints do
  let(:migration_validator) { 
    create(:migration_validator, table_name: :table_name, 
                                 validation_type: :uniqueness, 
                                 options: { as: :trigger, 
                                            update_trigger_name: :trg_table_name_upd, 
                                            on: :update }) 
  }

  let(:trigger_description) { Mv::Core::Constraint::Description.new(:trg_table_name_upd, 
                                                                    :trigger, 
                                                                    event: :update)}

  before do
    Mv::Core::Services::CreateMigrationValidatorsTable.new.execute
    migration_validator
  end

  subject(:service) { described_class.new(tables) }

  describe "#initialize" do
    describe "when tables list specified" do
      let(:tables) { [:table_name_1] }

      its(:tables) { is_expected.to eq([:table_name_1]) }
    end

    describe "when tables list not specified" do
      let(:tables) { [] }

      its(:tables) { is_expected.to eq(["table_name"]) }
    end
  end

  describe "#execute" do
    describe "when existing table name specified" do
      let(:tables) { [:table_name] }

      subject { service.execute }

      it 'displays constraint' do
        expect(::ActiveRecord::Migration).to receive(:say_with_time).with("#{Mv::Core::Presenter::Constraint::Description.new(trigger_description)}")

        subject
      end

      it 'displays vlaidation' do
        expect(::ActiveRecord::Migration).to receive(:say).with("#{Mv::Core::Presenter::Validation::Base.new(migration_validator.validation)}", true)

        subject
      end
    end

    describe "when not existing table of table without constraints specified" do
      let(:tables) { [:table_name_1] }

      subject { service.execute }

      it "does not say anything" do
        expect(::ActiveRecord::Migration).not_to receive(:say)
        expect(::ActiveRecord::Migration).not_to receive(:say_with_time)

        subject      
      end
    end
  end
end